import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

const CHATWOOT_COLOR_PRIMARY = Color(0xff1f93ff);
const CHATWOOT_BG_COLOR = Color(0xfff4f6fb);
const CHATWOOT_AVATAR_COLORS = [CHATWOOT_COLOR_PRIMARY];
const NEUTRAL_2 = Colors.grey;
const NEUTRAL_0 = Colors.black26;
const NEUTRAL_7 = Colors.black;
const NEUTRAL_7_WITH_OPACITY = Colors.black54;
const PRIMARY = CHATWOOT_COLOR_PRIMARY;

/// Default chatwoot chat theme. Use [toChatTheme] to obtain the equivalent
/// flutter_chat_ui [ChatTheme].
@immutable
class ChatwootChatTheme {
  /// Background color of the chat page
  final Color backgroundColor;

  /// Style of the date divider shown between messages sent on different days
  final TextStyle dateDividerTextStyle;

  /// Style of the placeholder shown when there are no messages
  final TextStyle emptyChatPlaceholderTextStyle;

  /// Color used for error states, e.g. messages that failed to send
  final Color errorColor;

  /// Background color of the input composer
  final Color inputBackgroundColor;

  /// Fill color of the input text field
  final Color inputFillColor;

  /// Color of the text typed in the input text field
  final Color inputTextColor;

  /// Style of the text typed in the input text field
  final TextStyle inputTextStyle;

  /// Border radius of message bubbles
  final double messageBorderRadius;

  /// Primary color, used as background of sent messages
  final Color primaryColor;

  /// Style of the body of received messages
  final TextStyle receivedMessageBodyTextStyle;

  /// Style of the time shown on received messages
  final TextStyle receivedMessageCaptionTextStyle;

  /// Secondary color, used as background of received messages
  final Color secondaryColor;

  /// Icon of the send button
  final Widget? sendButtonIcon;

  /// Style of the body of sent messages
  final TextStyle sentMessageBodyTextStyle;

  /// Style of the time shown on sent messages
  final TextStyle sentMessageCaptionTextStyle;

  /// Colors used for avatar placeholders and user names, picked by user id
  final List<Color> userAvatarNameColors;

  /// Style of the user names shown above received messages
  final TextStyle userNameTextStyle;

  /// Margin around the date divider
  final EdgeInsets dateDividerMargin;

  /// Maximum width of a message bubble
  final double messageMaxWidth;

  /// Creates a chatwoot chat theme. Use this constructor if you want to
  /// override only a couple of variables.
  const ChatwootChatTheme({
    this.backgroundColor = CHATWOOT_BG_COLOR,
    this.dateDividerTextStyle = const TextStyle(
      color: Colors.black26,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
    this.emptyChatPlaceholderTextStyle = const TextStyle(
      color: NEUTRAL_2,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    this.errorColor = Colors.red,
    this.inputBackgroundColor = Colors.white,
    this.inputFillColor = CHATWOOT_BG_COLOR,
    this.inputTextColor = Colors.black87,
    this.inputTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    this.messageBorderRadius = 20.0,
    this.primaryColor = CHATWOOT_COLOR_PRIMARY,
    this.receivedMessageBodyTextStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    this.receivedMessageCaptionTextStyle = const TextStyle(
      color: NEUTRAL_2,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
    ),
    this.secondaryColor = Colors.white,
    this.sendButtonIcon,
    this.sentMessageBodyTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    this.sentMessageCaptionTextStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
    ),
    this.userAvatarNameColors = CHATWOOT_AVATAR_COLORS,
    this.userNameTextStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
    this.dateDividerMargin = const EdgeInsets.all(8),
    this.messageMaxWidth = 500,
  });

  /// Returns a color from [userAvatarNameColors] for the given user id
  Color colorForUser(String userId) =>
      userAvatarNameColors[userId.hashCode.abs() % userAvatarNameColors.length];

  /// Converts this theme to a flutter_chat_ui [ChatTheme]
  ChatTheme toChatTheme() {
    final base = ChatTheme.light();
    return base.copyWith(
      colors: base.colors.copyWith(
        primary: primaryColor,
        onPrimary: sentMessageBodyTextStyle.color ?? Colors.white,
        surface: backgroundColor,
        onSurface: receivedMessageBodyTextStyle.color ?? Colors.black87,
        surfaceContainer: secondaryColor,
        surfaceContainerLow: inputBackgroundColor,
        surfaceContainerHigh: inputFillColor,
      ),
      typography: base.typography.copyWith(
        bodyLarge: emptyChatPlaceholderTextStyle,
        bodyMedium: inputTextStyle,
        labelMedium: userNameTextStyle,
      ),
      shape: BorderRadius.all(Radius.circular(messageBorderRadius)),
    );
  }
}
