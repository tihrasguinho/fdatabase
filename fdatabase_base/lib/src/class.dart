import 'parameter.dart';

class Class {
  final Type type;
  final Function constructor;
  final List<Parameter> parameters;

  const Class({required this.type, required this.constructor, required this.parameters});

  Class copyWith({
    Type? type,
    Function? constructor,
    List<Parameter>? parameters,
  }) {
    return Class(
      type: type ?? this.type,
      constructor: constructor ?? this.constructor,
      parameters: parameters ?? this.parameters,
    );
  }

  dynamic invoke([List<Parameter>? parameters]) {
    final all = parameters ?? this.parameters;

    return Function.apply(
      constructor,
      all.whereType<PositionalParameter>().map((e) => e.value).toList(),
      all.whereType<NamedParameter>().fold(<Symbol, dynamic>{}, (prev, next) => {...?prev, next.named: next.value}),
    );
  }

  @override
  String toString() {
    return 'Class(type: $type, constructor: $constructor, parameters: $parameters)';
  }
}
