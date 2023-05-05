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
  smallAce(weight: 11, stringRepresentation: 'A');

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

  Hand(this.cards);

  @override
  String toString() {
    String stringHand = '';
    for (Card card in cards) {
      stringHand += card.toString();
    }
    return stringHand;
  }

  // TODO: create logic with Aces on hand (11 or 1 weights)
  int get getScore {
    int score = cards.fold(0, (a, b) => a + b.weight);
    return score;
  }

  void putCard(Card card) => cards.add(card);
}


class PlayingDeck {
  final List deck = <Card>[
    Card(CardValue.ace, CardSuit.club),
    Card(CardValue.ace, CardSuit.spade),
    Card(CardValue.ace, CardSuit.diamond),
    Card(CardValue.ace, CardSuit.heart),
    Card(CardValue.two, CardSuit.club),
    Card(CardValue.two, CardSuit.spade),
    Card(CardValue.two, CardSuit.diamond),
    Card(CardValue.two, CardSuit.heart),
    Card(CardValue.three, CardSuit.club),
    Card(CardValue.three, CardSuit.spade),
    Card(CardValue.three, CardSuit.diamond),
    Card(CardValue.three, CardSuit.heart),
    Card(CardValue.four, CardSuit.club),
    Card(CardValue.four, CardSuit.spade),
    Card(CardValue.four, CardSuit.diamond),
    Card(CardValue.four, CardSuit.heart),
    Card(CardValue.five, CardSuit.club),
    Card(CardValue.five, CardSuit.spade),
    Card(CardValue.five, CardSuit.diamond),
    Card(CardValue.five, CardSuit.heart),
    Card(CardValue.six, CardSuit.club),
    Card(CardValue.six, CardSuit.spade),
    Card(CardValue.six, CardSuit.diamond),
    Card(CardValue.six, CardSuit.heart),
    Card(CardValue.seven, CardSuit.club),
    Card(CardValue.seven, CardSuit.spade),
    Card(CardValue.seven, CardSuit.diamond),
    Card(CardValue.seven, CardSuit.heart),
    Card(CardValue.eight, CardSuit.club),
    Card(CardValue.eight, CardSuit.spade),
    Card(CardValue.eight, CardSuit.diamond),
    Card(CardValue.eight, CardSuit.heart),
    Card(CardValue.nine, CardSuit.club),
    Card(CardValue.nine, CardSuit.spade),
    Card(CardValue.nine, CardSuit.diamond),
    Card(CardValue.nine, CardSuit.heart),
    Card(CardValue.ten, CardSuit.club),
    Card(CardValue.ten, CardSuit.spade),
    Card(CardValue.ten, CardSuit.diamond),
    Card(CardValue.ten, CardSuit.heart),
    Card(CardValue.jack, CardSuit.club),
    Card(CardValue.jack, CardSuit.spade),
    Card(CardValue.jack, CardSuit.diamond),
    Card(CardValue.jack, CardSuit.heart),
    Card(CardValue.queen, CardSuit.club),
    Card(CardValue.queen, CardSuit.spade),
    Card(CardValue.queen, CardSuit.diamond),
    Card(CardValue.queen, CardSuit.heart),
    Card(CardValue.king, CardSuit.club),
    Card(CardValue.king, CardSuit.spade),
    Card(CardValue.king, CardSuit.diamond),
    Card(CardValue.king, CardSuit.heart),
  ];

  void shuffleDeck() => deck.shuffle();
  Card get getCard => deck.removeAt(0);
}
