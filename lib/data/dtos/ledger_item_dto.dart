import 'package:json_annotation/json_annotation.dart';
import 'package:trueledger/domain/models/ledger_item_model.dart';
import 'package:trueledger/domain/models/transaction_tag.dart';

part 'ledger_item_dto.g.dart';

@JsonSerializable()
class LedgerItemDto {
  final int id;
  final String? name;
  final String? category;
  final String? source;
  @JsonKey(defaultValue: 0.0)
  final double amount;
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(name: 'entryType', defaultValue: 'Variable')
  final String type;
  final String? note;
  final String? tags;

  LedgerItemDto({
    required this.id,
    this.name,
    this.category,
    this.source,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
    this.tags,
  });

  factory LedgerItemDto.fromJson(Map<String, dynamic> json) =>
      _$LedgerItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LedgerItemDtoToJson(this);

  factory LedgerItemDto.fromDomain(LedgerItem domain) {
    return LedgerItemDto(
      id: domain.id,
      name: domain.type != 'Income' && domain.type != 'Variable'
          ? domain.label
          : null,
      category: domain.type == 'Variable' ? domain.label : null,
      source: domain.type == 'Income' ? domain.label : null,
      amount: domain.amount,
      date: domain.date.toUtc().toIso8601String(),
      type: domain.type,
      note: domain.note,
      tags: domain.tags.map((t) => t.name).join(','),
    );
  }

  LedgerItem toDomain() {
    String label = "Unknown";
    if (name != null) {
      label = name!;
    } else if (category != null) {
      label = category!;
    } else if (source != null) {
      label = source!;
    }

    final tagSet = (tags == null || tags!.isEmpty)
        ? <TransactionTag>{}
        : tags!
            .split(',')
            .map((s) => TransactionTagHelper.fromString(s.trim()))
            .toSet();

    return LedgerItem(
      id: id,
      label: label,
      amount: amount,
      date: DateTime.parse(date),
      type: type,
      note: note,
      tags: tagSet,
    );
  }
}
