enum CardSuit {
  diamond(stringRepresentation: '♦︎'),
  heart(stringRepresentation: '♥︎'),
  club(stringRepresentation: '♣︎'),
  spade(stringRepresentation: '♠︎');

  const CardSuit({
    required this.stringRepresentation
  });

  final String stringRepresentation;
}


enum CardValue {
  two(weight: 2, stringRepresentation: '2'),
  three(weight: 3, stringRepresentation: '3'),
  four(weight: 4, stringRepresentation: '4'),
  five(weight: 5, stringRepresentation: '5'),
  six(weight: 6, stringRepresentation: '6'),
  seven(weight: 7, stringRepresentation: '7'),
  eight(weight: 8, stringRepresentation: '8'),
  nine(weight: 9, stringRepresentation: '9'),
  ten(weight: 10, stringRepresentation: '10'),
  jack(weight: 10, stringRepresentation: 'J'),
  queen(weight: 10, stringRepresentation: 'Q'),
  king(weight: 10, stringRepresentation: 'K'),
  ace(weight: 11, stringRepresentation: 'A'),
  smallAce(weight: 1, stringRepresentation: 'A');

  const CardValue({
    required this.weight,
    required this.stringRepresentation
  });

  final int weight;
  final String stringRepresentation;
}


class Card {
  CardValue cardValue;
  CardSuit cardSuit;

  Card(this.cardValue, this.cardSuit);

  int get weight => cardValue.weight;

  @override
  String toString() {
    return '${cardValue.stringRepresentation}${cardSuit.stringRepresentation}';
  }
}


class Hand {
  List<Card> cards;

  Hand(this.cards) {
    if (cards[0].cardValue == CardValue.ace && cards[1].cardValue == CardValue.ace) {
      _tryToFixAce();
    }
  }

  void _tryToFixAce() {
    if (getScore > 21) {
      int aceIndex = cards.indexWhere((card) => card.cardValue == CardValue.ace);
      if (aceIndex != -1) {
        cards[aceIndex] = Card(CardValue.smallAce, cards[aceIndex].cardSuit);
      }
    }
  }

  @override
  String toString() {
    String stringHand = '';
    for (Card card in cards) {
      stringHand += card.toString();
    }
    return stringHand;
  }

  int get getScore {
    int score = cards.fold(0, (a, b) => a + b.weight);
    return score;
  }

  void putCard(Card card) {
    cards.add(card);
    _tryToFixAce();
  }
}


class PlayingDeck {
  List<Card> deck = [];

  PlayingDeck() {
    for (CardValue cardValue in CardValue.values) {
      for (CardSuit cardSuit in CardSuit.values) {
        if (cardValue != CardValue.smallAce) {
          deck.add(Card(cardValue, cardSuit));
        }
      }
    }
  }

  void shuffleDeck() => deck.shuffle();
  Card get getCard => deck.removeAt(0);
}
