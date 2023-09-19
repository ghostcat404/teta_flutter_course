import 'package:flutter/material.dart';

final _mainRadius = BorderRadius.circular(8.0);
final _mainColor = Colors.grey[300];

class MessageWidgetShimmer extends StatelessWidget {
  const MessageWidgetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 20,
                decoration:
                    BoxDecoration(color: _mainColor, borderRadius: _mainRadius),
              ),
              const SizedBox(
                width: 6,
              ),
              Container(
                width: 100,
                height: 20,
                decoration:
                    BoxDecoration(color: _mainColor, borderRadius: _mainRadius),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                      color: _mainColor, borderRadius: _mainRadius),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ListMessagesShimmer extends StatelessWidget {
  const ListMessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('ListMessagesShimmer'),
      appBar: AppBar(
        title: Container(
          width: 400,
          height: 30,
          decoration:
              BoxDecoration(color: _mainColor, borderRadius: _mainRadius),
        ),
      ),
      body: ListView.separated(
          itemCount: 3,
          reverse: true,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (context, index) {
            return const MessageWidgetShimmer();
          }),
      bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                    style: TextStyle(fontSize: 16.0),
                    decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0))),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send),
                color: Colors.blue[900],
              )
            ],
          )),
    );
  }
}
