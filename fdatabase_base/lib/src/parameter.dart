sealed class Parameter {
  final String type;
  final bool nullable;
  final dynamic value;

  const Parameter({required this.type, required this.nullable, this.value});

  Parameter setValue(dynamic value);
}

final class NamedParameter extends Parameter {
  final Symbol named;

  const NamedParameter({
    required super.type,
    required super.nullable,
    required this.named,
    super.value,
  });

  @override
  Parameter setValue(value) {
    return NamedParameter(
      type: type,
      nullable: nullable,
      named: named,
      value: value,
    );
  }

  @override
  String toString() {
    return 'NamedParameter(type: $type, nullable: $nullable, named: $named, value: $value)';
  }
}

final class PositionalParameter extends Parameter {
  const PositionalParameter({required super.type, required super.nullable, super.value});

  @override
  Parameter setValue(value) {
    return PositionalParameter(
      type: type,
      nullable: nullable,
      value: value,
    );
  }

  @override
  String toString() {
    return 'PositionalParameter(type: $type, nullable: $nullable, value: $value)';
  }
}
