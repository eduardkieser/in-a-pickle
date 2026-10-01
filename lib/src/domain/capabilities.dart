class HelperCapability {
  const HelperCapability(
      {required this.id, required this.title, required this.hint});

  final String id;
  final String title;
  final String hint;
}

const kHelperCapabilities = <HelperCapability>[
  HelperCapability(
      id: 'dogs', title: 'Dogs', hint: 'Walking, feeding or sitting'),
  HelperCapability(
      id: 'cats', title: 'Cats', hint: 'Feeding, medicine or sitting'),
  HelperCapability(
      id: 'children', title: 'Children', hint: 'A short watch or school run'),
  HelperCapability(
      id: 'driving', title: 'Driving', hint: 'Lifts and collections'),
  HelperCapability(
      id: 'errands', title: 'Errands', hint: 'Shopping and prescriptions'),
  HelperCapability(
      id: 'practical', title: 'Practical jobs', hint: 'Small household fixes'),
  HelperCapability(
      id: 'technology', title: 'Technology', hint: 'Phones, TVs and computers'),
  HelperCapability(
    id: 'first_response',
    title: 'First response',
    hint: 'Trained medical, fire or rescue help',
  ),
  HelperCapability(
    id: 'anything',
    title: 'Anything — ask me',
    hint: 'Show me requests that do not fit a box',
  ),
];
