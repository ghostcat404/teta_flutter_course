import 'package:flutter/material.dart';

class MessageWidgetShimmer extends StatelessWidget {
  final _mainRadius = BorderRadius.circular(8.0);
  final _mainColor = Colors.grey[300];
  MessageWidgetShimmer({super.key});

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
                decoration: BoxDecoration(
                  color: _mainColor,
                  borderRadius: _mainRadius
                ),
              ),
              const SizedBox(width: 6,),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: _mainColor,
                  borderRadius: _mainRadius
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _mainColor,
                    borderRadius: _mainRadius
                  ),
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
      appBar: AppBar(title: const Text('Chat with user'),),
      body: ListView.separated(
        itemCount: 3,
        reverse: true,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          return MessageWidgetShimmer();
        }
      ),
      bottomNavigationBar:
        const BottomAppBar(
          child: TextField(
            style: TextStyle(fontSize: 16.0),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: 'Message',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)
            )
          )
        ),
    );
  }
}