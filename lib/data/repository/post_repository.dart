import 'package:bookcaffeine/data/model/post.dart';
import 'package:bookcaffeine/data/model/report.dart';
import 'package:bookcaffeine/util/global_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepository {
  final postCollectionRef = FirebaseFirestore.instance.collection('post');
  final reportCollectionRef = FirebaseFirestore.instance.collection('report');
  final userCollectionRef = FirebaseFirestore.instance.collection('user');

  /// 파이어베이스에서 post 문서 생성
  Future<void> insertPost(Post post) async {
    try {
      if (GlobalUserInfo.uid == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final postInfo = post.toJson();
      await postCollectionRef.add(postInfo);
    } catch (e) {
      // print('소감 저장 실패: $e');
      throw Exception('소감 저장에 실패했습니다.');
    }
  }

  Future<List<Post>?> getPostsByBookIdWithoutReported(String bookId) async {
    try {
      // 1. 신고한 postId 목록 가져오기
      final reportedPostsSnapshot =
          await reportCollectionRef.doc(GlobalUserInfo.uid).get();
      var reportedPostIds = <String>[];

      // 신고된 postId 목록이 존재하면 가져오기
      if (reportedPostsSnapshot.exists) {
        final data = reportedPostsSnapshot.data();
        if (data != null && data['postId'] != null) {
          reportedPostIds = (data['postId'] as List)
              .map((item) => (item as Map<String, dynamic>)['postId'] as String)
              .toList();
        }
      }

      // 2. bookId로 포스트 가져오기 (isDeleted 필터링은 하지 않음)
      final postsSnapshot = await postCollectionRef
          .where('bookId', isEqualTo: bookId)
          .orderBy('createdAt', descending: true)
          .get();

      // 3. 가져온 포스트에서 isDeleted가 false인 포스트만 필터링
      final nonDeletedPosts = postsSnapshot.docs
          .map((doc) => Post.fromFirestore(doc, postId: doc.id))
          .where((post) => post.isDeleted == false) // isDeleted 필터링
          .toList();

      // 4. 신고된 postId 목록에 포함된 포스트 제외
      final filteredPosts = nonDeletedPosts
          .where((post) => !reportedPostIds.contains(post.postId)) // 신고된 포스트 제외
          .toList();

      return filteredPosts;
    } catch (e) {
      // 오류 처리
      print('Error getting posts by bookId: $e');
      return null;
    }
  }

  /// 파이어베이스 post 문서 수정
  Future<void> updatePost(Post post, postId) async {
    try {
      final postInfo = post.toJson();
      await postCollectionRef.doc(postId).set(postInfo);
    } catch (e) {
      print('updatePost 에러: $e');
    }
  }

  /// 파이어베이스 post 문서 삭제
  Future<void> deletePost(String postId) async {
    try {
      // // 1. 문서 참조 가져오기
      final postRef = postCollectionRef.doc(postId);

      // // 2. isDeleted 필드를 true로 업데이트
      await postRef.update({'isDeleted': true});
    } catch (e) {
      print('updatePost 에러: $e');
    }
  }

  /// 신고 기능
  Future<void> reportPost(Report report, String userId) async {
    try {
      final reportInfo = report.toJson();

      final docRef = reportCollectionRef.doc(userId);

      // Firestore에서 문서가 존재하는지 확인
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Firestore 문서에 'postId' 필드가 이미 있을 경우, 기존 리스트에 추가
        await docRef.update({
          'postId': FieldValue.arrayUnion(
            reportInfo['postId'],
          ),
        });
      } else {
        // 문서가 없다면, 새로 문서를 작성하면서 'postId' 추가
        await docRef.set({
          'postId': reportInfo['postId'],
        });
      }
    } catch (e) {
      print('reportPost 에러: $e');
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike(String postId, String userId) async {
    try {
      // 1. post 문서의 like 컬렉션 참조
      final likeRef = postCollectionRef.doc(postId).collection('like');

      // 2. 현재 사용자의 좋아요 문서 확인
      final likeDoc = await likeRef.doc(userId).get();

      // 트랜잭션으로 좋아요 처리
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        if (likeDoc.exists) {
          // 좋아요 취소
          await likeRef.doc(userId).delete();
          await userCollectionRef
              .doc(userId)
              .collection('my_like')
              .doc(postId)
              .delete();
        } else {
          // 좋아요 추가
          await likeRef.doc(userId).set({
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await userCollectionRef
              .doc(userId)
              .collection('my_like')
              .doc(postId)
              .set({
            'postId': postId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('toggleLike 에러: $e');
      throw Exception('좋아요 처리 중 오류가 발생했습니다.');
    }
  }

  /// 좋아요 상태 확인
  Future<bool> checkIsLiked(String postId, String userId) async {
    try {
      final likeDoc = await postCollectionRef
          .doc(postId)
          .collection('like')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      print('checkIsLiked 에러: $e');
      return false;
    }
  }

  /// 좋아요 수 가져오기
  Future<int?> getLikeCount(String postId) async {
    try {
      final likeSnapshot =
          await postCollectionRef.doc(postId).collection('like').count().get();
      return likeSnapshot.count;
    } catch (e) {
      print('getLikeCount 에러: $e');
      return 0;
    }
  }

  Future<List<Post>> getLikedPosts(String userId) async {
    try {
      final querySnapshot = await postCollectionRef
          .where('likes', arrayContains: userId)
          .where('isDeleted', isEqualTo: false) // isDeleted가 false인 것만 필터링
          .get();

      return querySnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('좋아요한 게시물을 불러오는데 실패했습니다.');
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final querySnapshot = await postCollectionRef
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false) // isDeleted가 false인 것만 필터링
          .get();

      return querySnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('사용자의 게시물을 불러오는데 실패했습니다.');
    }
  }
}
