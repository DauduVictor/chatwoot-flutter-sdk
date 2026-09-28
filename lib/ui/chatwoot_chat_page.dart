import 'package:chatwoot_sdk/chatwoot_callbacks.dart';
import 'package:chatwoot_sdk/chatwoot_client.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_message.dart';
import 'package:chatwoot_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_sdk/data/remote/chatwoot_client_exception.dart';
import 'package:chatwoot_sdk/ui/chatwoot_chat_theme.dart';
import 'package:chatwoot_sdk/ui/chatwoot_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

///Chatwoot chat widget
/// {@category FlutterClientSdk}
@deprecated
class ChatwootChat extends StatefulWidget {
  /// Specifies a custom app bar for chatwoot page widget
  final PreferredSizeWidget? appBar;

  ///Installation url for chatwoot
  final String baseUrl;

  ///Identifier for target chatwoot inbox.
  ///
  /// For more details see https://www.chatwoot.com/docs/product/channels/api/client-apis
  final String inboxIdentifier;

  /// Enables persistence of chatwoot client instance's contact, conversation and messages to disk
  /// for convenience.
  ///
  /// Setting [enablePersistence] to false holds chatwoot client instance's data in memory and is cleared as
  /// soon as chatwoot client instance is disposed
  final bool enablePersistence;

  /// Custom user details to be attached to chatwoot contact
  final ChatwootUser? user;

  /// See [ChatAnimatedList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatAnimatedList.paginationThreshold]
  final double? onEndReachedThreshold;

  /// See [Chat.onMessageLongPress]
  final void Function(BuildContext context, Message)? onMessageLongPress;

  /// See [Chat.onMessageTap]
  final void Function(Message)? onMessageTap;

  /// See [Chat.onMessageSend]
  final void Function(String)? onSendPressed;

  /// Show avatars for received messages.
  final bool showUserAvatars;

  /// Show user names for received messages.
  final bool showUserNames;

  final ChatwootChatTheme? theme;

  /// See [ChatwootL10n]
  final ChatwootL10n l10n;

  /// See [Chat.timeFormat]
  final DateFormat? timeFormat;

  /// Format of the date divider shown between messages sent on different days
  final DateFormat? dateFormat;

  ///See [ChatwootCallbacks.onWelcome]
  final void Function()? onWelcome;

  ///See [ChatwootCallbacks.onPing]
  final void Function()? onPing;

  ///See [ChatwootCallbacks.onConfirmedSubscription]
  final void Function()? onConfirmedSubscription;

  ///See [ChatwootCallbacks.onConversationStartedTyping]
  final void Function()? onConversationStartedTyping;

  ///See [ChatwootCallbacks.onConversationIsOnline]
  final void Function()? onConversationIsOnline;

  ///See [ChatwootCallbacks.onConversationIsOffline]
  final void Function()? onConversationIsOffline;

  ///See [ChatwootCallbacks.onConversationStoppedTyping]
  final void Function()? onConversationStoppedTyping;

  ///See [ChatwootCallbacks.onMessageReceived]
  final void Function(ChatwootMessage)? onMessageReceived;

  ///See [ChatwootCallbacks.onMessageSent]
  final void Function(ChatwootMessage)? onMessageSent;

  ///See [ChatwootCallbacks.onMessageDelivered]
  final void Function(ChatwootMessage)? onMessageDelivered;

  ///See [ChatwootCallbacks.onMessageUpdated]
  final void Function(ChatwootMessage)? onMessageUpdated;

  ///See [ChatwootCallbacks.onPersistedMessagesRetrieved]
  final void Function(List<ChatwootMessage>)? onPersistedMessagesRetrieved;

  ///See [ChatwootCallbacks.onMessagesRetrieved]
  final void Function(List<ChatwootMessage>)? onMessagesRetrieved;

  ///See [ChatwootCallbacks.onError]
  final void Function(ChatwootClientException)? onError;

  ///Horizontal padding is reduced if set to true
  final bool isPresentedInDialog;

  const ChatwootChat(
      {Key? key,
      required this.baseUrl,
      required this.inboxIdentifier,
      this.enablePersistence = true,
      this.user,
      this.appBar,
      this.onEndReached,
      this.onEndReachedThreshold,
      this.onMessageLongPress,
      this.onMessageTap,
      this.onSendPressed,
      this.showUserAvatars = true,
      this.showUserNames = true,
      this.theme,
      this.l10n = const ChatwootL10n(),
      this.timeFormat,
      this.dateFormat,
      this.onWelcome,
      this.onPing,
      this.onConfirmedSubscription,
      this.onMessageReceived,
      this.onMessageSent,
      this.onMessageDelivered,
      this.onMessageUpdated,
      this.onPersistedMessagesRetrieved,
      this.onMessagesRetrieved,
      this.onConversationStartedTyping,
      this.onConversationStoppedTyping,
      this.onConversationIsOnline,
      this.onConversationIsOffline,
      this.onError,
      this.isPresentedInDialog = false})
      : super(key: key);

  @override
  _ChatwootChatState createState() => _ChatwootChatState();
}

@deprecated
class _ChatwootChatState extends State<ChatwootChat> {
  final _chatController = InMemoryChatController();

  /// Users referenced by messages, used to resolve avatars and names
  final Map<UserID, User> _users = {};

  late String status;

  final idGen = Uuid();
  late final User _user;
  ChatwootClient? chatwootClient;

  late final ChatwootCallbacks chatwootCallbacks;

  ChatwootChatTheme get _theme => widget.theme ?? const ChatwootChatTheme();

  @override
  void initState() {
    super.initState();

    if (widget.user == null) {
      _user = User(id: idGen.v4());
    } else {
      _user = User(
        id: widget.user?.identifier ?? idGen.v4(),
        name: widget.user?.name,
        imageSource: widget.user?.avatarUrl,
      );
    }
    _users[_user.id] = _user;

    chatwootCallbacks = ChatwootCallbacks(
      onWelcome: () {
        widget.onWelcome?.call();
      },
      onPing: () {
        widget.onPing?.call();
      },
      onConfirmedSubscription: () {
        widget.onConfirmedSubscription?.call();
      },
      onConversationStartedTyping: () {
        widget.onConversationStartedTyping?.call();
      },
      onConversationStoppedTyping: () {
        widget.onConversationStoppedTyping?.call();
      },
      onConversationIsOnline: () {
        widget.onConversationIsOnline?.call();
      },
      onConversationIsOffline: () {
        widget.onConversationIsOffline?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (widget.enablePersistence) {
          _chatController.setMessages(_mergeMessages(
              [],
              persistedMessages
                  .map((message) => _chatwootMessageToTextMessage(message))
                  .toList()));
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }
        final chatMessages = messages
            .map((message) => _chatwootMessageToTextMessage(message))
            .toList();
        _chatController.setMessages(
            _mergeMessages(_chatController.messages, chatMessages));
        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (chatwootMessage) {
        _addMessage(_chatwootMessageToTextMessage(chatwootMessage));
        widget.onMessageReceived?.call(chatwootMessage);
      },
      onMessageDelivered: (chatwootMessage, echoId) {
        _handleMessageSent(
            _chatwootMessageToTextMessage(chatwootMessage, echoId: echoId));
        widget.onMessageDelivered?.call(chatwootMessage);
      },
      onMessageUpdated: (chatwootMessage) {
        _handleMessageUpdated(_chatwootMessageToTextMessage(chatwootMessage,
            echoId: chatwootMessage.id.toString()));
        widget.onMessageUpdated?.call(chatwootMessage);
      },
      onMessageSent: (chatwootMessage, echoId) {
        final textMessage = TextMessage(
            id: echoId,
            authorId: _user.id,
            text: chatwootMessage.content ?? "",
            status: MessageStatus.delivered);
        _handleMessageSent(textMessage);
        widget.onMessageSent?.call(chatwootMessage);
      },
      onConversationResolved: () {
        final bot = User(
            id: idGen.v4(),
            name: "Bot",
            imageSource:
                "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png");
        _users[bot.id] = bot;
        final resolvedMessage = TextMessage(
            id: idGen.v4(),
            text: widget.l10n.conversationResolvedMessage,
            authorId: bot.id,
            createdAt: DateTime.now(),
            status: MessageStatus.delivered);
        _addMessage(resolvedMessage);
      },
      onError: (error) {
        if (error.type == ChatwootClientExceptionType.SEND_MESSAGE_FAILED) {
          _handleSendMessageFailed(error.data);
        }
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
        widget.onError?.call(error);
      },
    );

    ChatwootClient.create(
            baseUrl: widget.baseUrl,
            inboxIdentifier: widget.inboxIdentifier,
            user: widget.user,
            enablePersistence: widget.enablePersistence,
            callbacks: chatwootCallbacks)
        .then((client) {
      setState(() {
        chatwootClient = client;
        chatwootClient!.loadMessages();
      });
    }).onError((error, stackTrace) {
      widget.onError?.call(ChatwootClientException(
          error.toString(), ChatwootClientExceptionType.CREATE_CLIENT_FAILED));
      print("chatwoot client failed with error $error: $stackTrace");
    });
  }

  TextMessage _chatwootMessageToTextMessage(ChatwootMessage message,
      {String? echoId}) {
    String? avatarUrl = message.sender?.avatarUrl ?? message.sender?.thumbnail;

    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }

    final String authorId;
    if (message.isMine) {
      authorId = _user.id;
    } else {
      final author = User(
        id: message.sender?.id.toString() ?? idGen.v4(),
        name: message.sender?.name,
        imageSource: avatarUrl,
      );
      _users[author.id] = author;
      authorId = author.id;
    }

    return TextMessage(
        id: echoId ?? message.id.toString(),
        authorId: authorId,
        text: message.content ?? "",
        status: MessageStatus.seen,
        createdAt: DateTime.parse(message.createdAt));
  }

  /// Merges [incoming] into [existing] by id and sorts the result from oldest
  /// to newest, as expected by [ChatAnimatedList]
  List<Message> _mergeMessages(
      List<Message> existing, List<Message> incoming) {
    final merged = <MessageID, Message>{
      for (final message in existing) message.id: message,
      for (final message in incoming) message.id: message,
    }.values.toList();
    final now = DateTime.now();
    merged.sort((a, b) => (a.createdAt ?? now).compareTo(b.createdAt ?? now));
    return merged;
  }

  Message? _findMessage(MessageID id) {
    return _chatController.messages.where((m) => m.id == id).firstOrNull;
  }

  void _addMessage(Message message) {
    final existing = _findMessage(message.id);
    if (existing != null) {
      _chatController.updateMessage(existing, message);
    } else {
      _chatController.insertMessage(message);
    }
  }

  void _handleSendMessageFailed(String echoId) {
    final existing = _findMessage(echoId);
    if (existing == null) {
      return;
    }
    _chatController.updateMessage(
        existing, existing.copyWith(status: MessageStatus.error));
  }

  void _handleResendMessage(TextMessage message) {
    chatwootClient!.sendMessage(content: message.text, echoId: message.id);
    _chatController.updateMessage(
        message, message.copyWith(status: MessageStatus.sending));
  }

  void _handleMessageTap(BuildContext context, Message message,
      {required int index, required TapUpDetails details}) {
    if (message.status == MessageStatus.error && message is TextMessage) {
      _handleResendMessage(message);
    }
    widget.onMessageTap?.call(message);
  }

  void _handleMessageLongPress(BuildContext context, Message message,
      {required int index, required LongPressStartDetails details}) {
    widget.onMessageLongPress?.call(context, message);
  }

  void _handleMessageSent(Message message) {
    final existing = _findMessage(message.id);
    if (existing == null || existing.status == MessageStatus.seen) {
      return;
    }
    _chatController.updateMessage(existing,
        message.copyWith(createdAt: message.createdAt ?? existing.createdAt));
  }

  void _handleMessageUpdated(Message message) {
    final existing = _findMessage(message.id);
    if (existing == null) {
      return;
    }
    _chatController.updateMessage(existing, message);
  }

  void _handleSendPressed(String text) {
    final textMessage = TextMessage(
        authorId: _user.id,
        createdAt: DateTime.now(),
        id: const Uuid().v4(),
        text: text,
        status: MessageStatus.sending);

    _addMessage(textMessage);

    chatwootClient!
        .sendMessage(content: textMessage.text, echoId: textMessage.id);
    widget.onSendPressed?.call(text);
  }

  Future<User?> _resolveUser(UserID id) async => _users[id];

  Widget? _buildDateDivider(int index) {
    final messages = _chatController.messages;
    if (index >= messages.length) {
      return null;
    }
    final createdAt = messages[index].createdAt?.toLocal();
    if (createdAt == null) {
      return null;
    }
    if (index > 0) {
      final previousCreatedAt = messages[index - 1].createdAt?.toLocal();
      if (previousCreatedAt != null &&
          DateUtils.isSameDay(previousCreatedAt, createdAt)) {
        return null;
      }
    }
    final dateFormat = widget.dateFormat ?? DateFormat("EEEE MMMM d");
    return Padding(
      padding: _theme.dateDividerMargin,
      child: Center(
        child: Text(
          dateFormat.format(createdAt),
          style: _theme.dateDividerTextStyle,
        ),
      ),
    );
  }

  Builders _buildBuilders() {
    final theme = _theme;
    return Builders(
      textMessageBuilder: (context, message, index,
              {required isSentByMe, groupStatus}) =>
          SimpleTextMessage(
        message: message,
        index: index,
        constraints: BoxConstraints(maxWidth: theme.messageMaxWidth),
        sentBackgroundColor: message.status == MessageStatus.error
            ? theme.errorColor
            : theme.primaryColor,
        receivedBackgroundColor: theme.secondaryColor,
        sentTextStyle: theme.sentMessageBodyTextStyle,
        receivedTextStyle: theme.receivedMessageBodyTextStyle,
        timeStyle: isSentByMe
            ? theme.sentMessageCaptionTextStyle
            : theme.receivedMessageCaptionTextStyle,
      ),
      chatMessageBuilder: (context, message, index, animation, child,
          {isRemoved, required isSentByMe, groupStatus}) {
        final isFirstInGroup = groupStatus?.isFirst ?? true;
        final isLastInGroup = groupStatus?.isLast ?? true;
        final showAvatar = widget.showUserAvatars && !isSentByMe;
        final showName = widget.showUserNames && !isSentByMe && isFirstInGroup;
        return ChatMessage(
          message: message,
          index: index,
          animation: animation,
          isRemoved: isRemoved,
          groupStatus: groupStatus,
          headerWidget: _buildDateDivider(index),
          leadingWidget: showAvatar
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: isLastInGroup
                      ? Avatar(
                          userId: message.authorId,
                          backgroundColor:
                              theme.colorForUser(message.authorId),
                          foregroundColor: Colors.white,
                        )
                      : const SizedBox(width: 32),
                )
              : null,
          topWidget: showName
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Username(
                    userId: message.authorId,
                    style: theme.userNameTextStyle,
                  ),
                )
              : null,
          child: child,
        );
      },
      chatAnimatedListBuilder: (context, itemBuilder) => ChatAnimatedList(
        itemBuilder: itemBuilder,
        onEndReached: widget.onEndReached,
        paginationThreshold: widget.onEndReachedThreshold ?? 0.01,
        handleSafeArea: false,
      ),
      composerBuilder: (context) => Composer(
        hintText: widget.l10n.inputPlaceholder,
        sendIcon: theme.sendButtonIcon ?? const Icon(Icons.send),
        sendIconColor: theme.primaryColor,
        textColor: theme.inputTextColor,
        backgroundColor: theme.inputBackgroundColor,
        inputFillColor: theme.inputFillColor,
        handleSafeArea: false,
      ),
      emptyChatListBuilder: (context) => EmptyChatList(
        text: widget.l10n.emptyChatPlaceholder,
        textStyle: theme.emptyChatPlaceholderTextStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isPresentedInDialog ? 8.0 : 16.0;
    final theme = _theme;
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: theme.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              child: Chat(
                chatController: _chatController,
                currentUserId: _user.id,
                resolveUser: _resolveUser,
                onMessageSend: _handleSendPressed,
                onMessageTap: _handleMessageTap,
                onMessageLongPress: widget.onMessageLongPress != null
                    ? _handleMessageLongPress
                    : null,
                timeFormat: widget.timeFormat ?? DateFormat.Hm(),
                theme: theme.toChatTheme(),
                backgroundColor: theme.backgroundColor,
                builders: _buildBuilders(),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo_grey.png",
                    package: 'chatwoot_sdk',
                    width: 15,
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Powered by Chatwoot",
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    chatwootClient?.dispose();
    _chatController.dispose();
  }
}
