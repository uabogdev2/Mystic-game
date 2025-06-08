import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting DateTime

import '../../models/chat_message.dart';
import '../../models/game_state.dart'; // For GameChatContext
import '../../constants/design_constants.dart'; // TODO: Update path
import '../../utils/snackbar_utils.dart'; // TODO: Update path

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String currentUserId;
  final bool isHostView;
  final GameChatContext? chatContext;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    this.isHostView = false,
    this.chatContext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isMyMessage = message.senderId == currentUserId;
    final bool isSystemMessage = message.messageType != ChatMessageType.normal;

    Alignment bubbleAlignment = isMyMessage ? Alignment.centerRight : Alignment.centerLeft;
    if (isSystemMessage) {
      bubbleAlignment = Alignment.center;
    }

    BoxDecoration bubbleDecoration;
    TextStyle messageTextStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    TextStyle senderNameStyle = theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
    TextStyle timestampStyle = theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)) ?? const TextStyle();

    Gradient? userMessageGradient;
    Color? bubbleBackgroundColor;

    if (widget.chatContext != null && !isSystemMessage) {
      // Contextual styling for normal messages in game chat
      switch (widget.chatContext) {
        case GameChatContext.night_wolves:
          bubbleBackgroundColor = isMyMessage ? Colors.red[900]!.withOpacity(0.8) : Colors.red[700]!.withOpacity(0.7);
          messageTextStyle = messageTextStyle.copyWith(color: Colors.white70);
          senderNameStyle = senderNameStyle.copyWith(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold);
          timestampStyle = timestampStyle.copyWith(color: Colors.white54);
          break;
        case GameChatContext.night_silence:
        case GameChatContext.night_sorciere:
        case GameChatContext.night_voyante:
          bubbleBackgroundColor = isMyMessage ? Colors.blueGrey[800]!.withOpacity(0.8) : Colors.blueGrey[700]!.withOpacity(0.7);
          messageTextStyle = messageTextStyle.copyWith(color: Colors.blueGrey[100]);
          senderNameStyle = senderNameStyle.copyWith(color: Colors.blueGrey[200]?.withOpacity(0.9));
          timestampStyle = timestampStyle.copyWith(color: Colors.blueGrey[300]?.withOpacity(0.7));
          break;
        case GameChatContext.day_debate:
          bubbleBackgroundColor = isMyMessage ? theme.colorScheme.primary.withOpacity(0.85) : theme.colorScheme.secondaryContainer.withOpacity(0.85);
          messageTextStyle = messageTextStyle.copyWith(color: isMyMessage ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer);
          senderNameStyle = senderNameStyle.copyWith(color: (isMyMessage ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer).withOpacity(0.9));
          timestampStyle = timestampStyle.copyWith(color: (isMyMessage ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer).withOpacity(0.7));
          break;
        case GameChatContext.dead_observers:
          bubbleBackgroundColor = isMyMessage ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey[700]!.withOpacity(0.6);
          messageTextStyle = messageTextStyle.copyWith(color: Colors.grey[400], fontStyle: FontStyle.italic);
          senderNameStyle = senderNameStyle.copyWith(color: Colors.grey[500]?.withOpacity(0.9));
          timestampStyle = timestampStyle.copyWith(color: Colors.grey[600]?.withOpacity(0.7));
          break;
        default:
          break;
      }
    }

    if (bubbleBackgroundColor == null && userMessageGradient == null && !isSystemMessage) {
      if (isMyMessage) {
        userMessageGradient = LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.8), theme.colorScheme.primary.withOpacity(1.0)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        );
        messageTextStyle = messageTextStyle.copyWith(color: theme.colorScheme.onPrimary);
        senderNameStyle = senderNameStyle.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.9));
        timestampStyle = timestampStyle.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.7));
      } else { // Other users' normal messages (Lobby context or unstyled Game context)
        userMessageGradient = LinearGradient(
          colors: [theme.colorScheme.secondaryContainer.withOpacity(0.7), theme.colorScheme.secondaryContainer],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        );
        messageTextStyle = messageTextStyle.copyWith(color: theme.colorScheme.onSecondaryContainer);
        senderNameStyle = senderNameStyle.copyWith(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9));
        timestampStyle = timestampStyle.copyWith(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7));
      }
    }

    if (!isSystemMessage) {
        bubbleDecoration = BoxDecoration(
        gradient: userMessageGradient,
        color: bubbleBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(kBorderRadiusMedium),
          topRight: const Radius.circular(kBorderRadiusMedium),
          bottomLeft: isMyMessage ? const Radius.circular(kBorderRadiusMedium) : Radius.zero,
          bottomRight: !isMyMessage ? const Radius.circular(kBorderRadiusMedium) : Radius.zero,
        ),
      );
    } else {
      Color systemMessageColor = theme.colorScheme.onSurface.withOpacity(0.6);
      // ... (system message styling from previous version, ensure messageTextStyle, senderNameStyle, timestampStyle are correctly set for system messages too) ...
      switch (message.messageType) {
        case ChatMessageType.system: systemMessageColor = theme.colorScheme.tertiary.withOpacity(0.9); break;
        case ChatMessageType.announcement:
           systemMessageColor = theme.colorScheme.tertiaryContainer;
           messageTextStyle = messageTextStyle.copyWith(color: theme.colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold);
           senderNameStyle = senderNameStyle.copyWith(color: theme.colorScheme.onTertiaryContainer.withOpacity(0.9));
           timestampStyle = timestampStyle.copyWith(color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7));
          break;
        case ChatMessageType.playerJoin: systemMessageColor = Colors.green.shade600; break;
        case ChatMessageType.playerLeave: systemMessageColor = Colors.orange.shade700; break;
        case ChatMessageType.hostAction: systemMessageColor = theme.colorScheme.primary.withOpacity(0.9); break;
        case ChatMessageType.roleReveal:
            systemMessageColor = theme.colorScheme.secondary;
            messageTextStyle = messageTextStyle.copyWith(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold);
            senderNameStyle = senderNameStyle.copyWith(color: theme.colorScheme.onSecondary.withOpacity(0.9));
            timestampStyle = timestampStyle.copyWith(color: theme.colorScheme.onSecondary.withOpacity(0.7));
          break;
        default: systemMessageColor = theme.colorScheme.onSurface.withOpacity(0.6);
      }
      bool useDistinctBackgroundForSystem = message.messageType == ChatMessageType.announcement || message.messageType == ChatMessageType.roleReveal;
      bubbleDecoration = BoxDecoration(
        color: useDistinctBackgroundForSystem ? systemMessageColor.withOpacity(0.15) : systemMessageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        border: Border.all(
          color: useDistinctBackgroundForSystem ? systemMessageColor.withOpacity(0.3) : systemMessageColor.withOpacity(0.2),
          width: 0.5
        )
      );
      if (messageTextStyle.color == theme.textTheme.bodyMedium?.color || messageTextStyle.color == null && !useDistinctBackgroundForSystem) {
         messageTextStyle = theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: systemMessageColor) ?? TextStyle(fontStyle: FontStyle.italic, color: systemMessageColor);
      }
       if ((senderNameStyle.color == theme.textTheme.bodySmall?.color?.withOpacity(0.9) || senderNameStyle.color == null) && !useDistinctBackgroundForSystem) {
        senderNameStyle = senderNameStyle.copyWith(color: systemMessageColor, fontWeight: FontWeight.normal);
      }
      if ((timestampStyle.color == theme.textTheme.bodySmall?.color?.withOpacity(0.7) || timestampStyle.color == null) && !useDistinctBackgroundForSystem) {
        timestampStyle = timestampStyle.copyWith(color: systemMessageColor.withOpacity(0.7));
      }
    }

    Widget messageMainContent = Column(
      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMyMessage && !isSystemMessage)
          Text(message.senderName, style: senderNameStyle),
        if (isSystemMessage && message.senderName != "Système")
           Text(message.senderName, style: senderNameStyle.copyWith(fontWeight: FontWeight.bold)),
        Text(message.content, style: messageTextStyle),
        const SizedBox(height: kSpacingXXXS),
        Text(
          DateFormat('HH:mm').format(message.timestamp),
          style: timestampStyle,
        ),
      ],
    );

    // Reactions Row (Placeholder)
    Widget? reactionsRow;
    if (message.messageType == ChatMessageType.normal) {
      reactionsRow = Padding(
        padding: const EdgeInsets.only(top: kSpacingXXS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => SnackbarUtils.showThemedSnackbar(context, "Ajouter réaction 👍 (Non implémenté)", type: SnackbarType.info),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingXXS),
                child: Icon(Icons.thumb_up_alt_outlined, size: 16, color: messageTextStyle.color?.withOpacity(0.6)),
              ),
            ),
            InkWell(
              onTap: () => SnackbarUtils.showThemedSnackbar(context, "Ajouter réaction ❤️ (Non implémenté)", type: SnackbarType.info),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingXXS),
                child: Icon(Icons.favorite_border_outlined, size: 16, color: messageTextStyle.color?.withOpacity(0.6)),
              ),
            ),
            InkWell(
                onTap: () => SnackbarUtils.showThemedSnackbar(context, "Plus de réactions (Non implémenté)", type: SnackbarType.info),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingXXS),
                child: Icon(Icons.add_reaction_outlined, size: 16, color: messageTextStyle.color?.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      );
    }

    // Combine message content and reactions
    Widget messageContentWithReactions = Column(
      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        messageMainContent,
        if (reactionsRow != null) reactionsRow,
      ],
    );

    List<Widget> actionIcons = [];
    final iconColor = isMyMessage
        ? theme.colorScheme.onPrimary.withOpacity(0.7)
        : (bubbleBackgroundColor != null ? messageTextStyle.color?.withOpacity(0.7) : theme.colorScheme.onSecondaryContainer.withOpacity(0.7));

    if (widget.isHostView && message.messageType == ChatMessageType.normal) {
      if(!isMyMessage) {
        actionIcons.addAll([
          Semantics(
            label: 'Rendre muet ${message.senderName}',
            child: IconButton(
              icon: Icon(Icons.mic_off_outlined, size: 16, color: iconColor),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: "Mute ${message.senderName} (placeholder)",
              onPressed: () => SnackbarUtils.showThemedSnackbar(context, "Mute ${message.senderName} (pas implémenté)", type: SnackbarType.info),
            ),
          ),
          Semantics(
            label: 'Exclure ${message.senderName}',
            child: IconButton(
              icon: Icon(Icons.person_remove_outlined, size: 16, color: iconColor),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: "Kick ${message.senderName} (placeholder)",
              onPressed: () => SnackbarUtils.showThemedSnackbar(context, "Kick ${message.senderName} (pas implémenté)", type: SnackbarType.info),
            ),
          ),
        ]);
      }
      actionIcons.add(
        Semantics(
          label: 'Épingler le message de ${message.senderName}',
          child: IconButton(
            icon: Icon(Icons.push_pin_outlined, size: 16, color: iconColor),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: "Épingler le message (placeholder)",
            onPressed: () => SnackbarUtils.showThemedSnackbar(context, "Épingler le message (pas implémenté)", type: SnackbarType.info),
          ),
        )
      );
    }

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: kSpacingXXS, horizontal: kSpacingXS),
        padding: const EdgeInsets.symmetric(vertical: kSpacingXS, horizontal: kSpacingSmall),
        decoration: bubbleDecoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: messageContentWithReactions),
            if (actionIcons.isNotEmpty) ...[
              const SizedBox(width: kSpacingXS),
              Row(mainAxisSize: MainAxisSize.min, children: actionIcons),
            ]
          ],
        ),
      ),
    );
  }
}
