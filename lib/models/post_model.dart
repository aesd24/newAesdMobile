import 'package:aesd_app/functions/formatteurs.dart';
import 'package:aesd_app/functions/navigation.dart';
import 'package:aesd_app/models/user_model.dart';
import 'package:aesd_app/screens/posts/detail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostModel {
  late int id;
  late String content;
  late String? image;
  late UserModel author;
  late DateTime date;
  bool liked = false;
  late int comments;
  late int likes;

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['contenu'];
    image = json['image'];
    author = UserModel.fromJson(json['user']);
    date = DateTime.parse(json['created_at']);
    liked = json['liked'];
    comments = json['comments_count'];
    likes = json['likes_count'];
  }

  getWidget(
    BuildContext context, {
    required Future Function(PostModel post) onLike,
  }) {
    return GestureDetector(
      onTap: () => pushForm(context,
          destination: SinglePost(
            post: this,
          )),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(author.photo!),
                    ),
                    SizedBox(width: 10),
                    Text(
                      author.name,
                      style: Theme.of(context).textTheme.titleMedium
                    )
                  ],
                ),
                Text(
                  formatDate(date),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.grey
                  ),
                )
              ],
            ),

            // Contenu du post
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            // Image contenu dans le post
            if (image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(7))),
              ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 20),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onLike(this),
                    icon: FaIcon(
                      liked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: liked ? Colors.red : Colors.black,
                    ),
                    label: Text("$likes likes"),
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                        overlayColor:
                            WidgetStateProperty.all(Colors.grey.shade200)),
                  ),
                  const SizedBox(width: 50),
                  TextButton.icon(
                    onPressed: () => pushForm(context,
                        destination:
                            SinglePost(post: this, isCommenting: true)),
                    icon: const FaIcon(
                      FontAwesomeIcons.comment,
                    ),
                    label: Text("$comments commentaires"),
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.black),
                        overlayColor:
                            WidgetStateProperty.all(Colors.grey.shade200)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PostPaginator {
  late List<PostModel> posts;
  int currentPage = 0;
  int totalPages = 1;

  PostPaginator();

  PostPaginator.fromJson(Map<String, dynamic> json) {
    posts =
        (json['posts'] as List).map((e) => PostModel.fromJson(e)).toList();
    currentPage = json['current_page'] ?? 0;
    totalPages = json['total_pages'] ?? 1;
  }
}