import 'dart:io';

import 'package:blackjack/cards.dart';
import 'package:blackjack/gamers.dart';


const String gamerTurn = 'Ход игрока (1 - Взять, 2 - Пас):';
const String dealerTurn = 'Ход дилера:';
const String delimiter = '—--------';
const String gamerWin = 'Игрок победил';
const String dealerWin = 'Дилер победил';
const String drawWin = 'Произошла Ничья';
const String gameStart = 'Раздача:';
const String continueQuestion = 'Играть еще? (y/N)';


void printGameStep(String dealerHand, String gamerHand) {
    print('Д: $dealerHand');
    print('И: $gamerHand');
    print(delimiter);
}

void printDealerWin() {
  print(dealerWin);
  print(delimiter);
  print(continueQuestion);
}

void printGamerWin() {
  print(gamerWin);
  print(delimiter);
  print(continueQuestion);
}

void printDraw() {
  print(drawWin);
  print(delimiter);
  print(continueQuestion);
}


void main(List<String> arguments) {
  String? continueGame = 'y';
  bool dealerWinFlg = false;
  bool gamerWinFlg = false;

  while (continueGame == 'y') {
    print(gameStart);
    PlayingDeck playingDeck = PlayingDeck();
    playingDeck.shuffleDeck();
    Gamer gamer = Gamer(Hand([playingDeck.getCard, playingDeck.getCard]));
    Dealer dealer = Dealer(Hand([playingDeck.getCard, playingDeck.getCard]));
    printGameStep(dealer.stringHand, gamer.stringHand);
    if (gamer.getScore > 21 || dealer.getScore == 21) {
      dealerWinFlg = true;
    }
    else if (dealer.getScore > 21) {
      gamerWinFlg = true;
    }
    else {
      String? gamerDecision = '1';
      while (gamerDecision == '1' && dealerWinFlg == false) {
        print(gamerTurn);
        gamerDecision = stdin.readLineSync();
        if (gamerDecision == null || gamerDecision == '') {
          print('Invalid decision, please try again');
          gamerDecision = '1';
          print(delimiter);
          continue;
        }
        print(delimiter);
        if (gamerDecision == '1') {
          gamer.putCardIntoHand(playingDeck.getCard);
          printGameStep(dealer.stringHand, gamer.stringHand);
          print('Gamer score: ${gamer.getScore}');
          print('Dealer score: ${dealer.getScore}');
          print(delimiter);
        }
        if (gamer.getScore > 21) {
          dealerWinFlg = true;
        }
        if (gamer.getScore == 21) {
          gamerWinFlg = true;
        }
      }
      if (dealerWinFlg != true) {
        dealer.isMyTurn = 1;
        printGameStep(dealer.stringHand, gamer.stringHand);
        print(delimiter);
        print('Dealer get cards');
        print(delimiter);
      }
    }
    if (dealer.getScore > gamer.getScore) {
      dealerWinFlg = true;
    }
    if (gamer.getScore > dealer.getScore) {
      gamerWinFlg = true;
    }
    if (dealerWinFlg == true) {
      printDealerWin();
    }
    else if (gamerWinFlg == true) {
      printGamerWin();
    }
    else {
      printDraw();
    }
    continueGame = stdin.readLineSync();
    print(delimiter);
  }
}
