import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/transaction_model.dart';
import '../providers/finance_provider.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(financeProvider.notifier);
    ref.watch(financeProvider);

    final balance = notifier.balance;
    final income = notifier.totalIncome;
    final expenses = notifier.totalExpenses;
    final recent = notifier.recentTransactions;
    final categories = notifier.categoryTotals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.lg),
            _buildHeader(),
            const SizedBox(height: AppSizes.lg),
            _buildBalanceCard(balance, income, expenses),
            const SizedBox(height: AppSizes.lg),
            if (categories.isNotEmpty) ...[
              _buildCategoryBreakdown(categories, expenses),
              const SizedBox(height: AppSizes.lg),
            ],
            _buildTransactionsList(context, ref, recent),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.financeStart,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() => ShaderMask(
        shaderCallback: (b) =>
            AppColors.financeGradient.createShader(b),
        child: const Text(
          AppStrings.financeTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      );

  Widget _buildBalanceCard(
      double balance, double income, double expenses) =>
      Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.financeGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.financeStart.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.totalBalance,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormatter.currency(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                    child: _StatPill(
                  label: AppStrings.income,
                  value: DateFormatter.currency(income),
                  icon: Icons.arrow_downward_rounded,
                  isPositive: true,
                )),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                    child: _StatPill(
                  label: AppStrings.expenses,
                  value: DateFormatter.currency(expenses),
                  icon: Icons.arrow_upward_rounded,
                  isPositive: false,
                )),
              ],
            ),
          ],
        ),
      );

  Widget _buildCategoryBreakdown(
      Map<TransactionCategory, double> categories, double total) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ...sorted.map((entry) => _CategoryBar(
              category: entry.key,
              amount: entry.value,
              total: total,
            )),
      ],
    );
  }

  Widget _buildTransactionsList(
      BuildContext context, WidgetRef ref, List<Transaction> recent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        if (recent.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.xl),
              child: Text(
                AppStrings.noTransactions,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          )
        else
          ...recent.map((t) => _TransactionTile(
                transaction: t,
                onDelete: () =>
                    ref.read(financeProvider.notifier).deleteTransaction(t.id),
              )),
      ],
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTransactionSheet(ref: ref),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPositive;
  const _StatPill(
      {required this.label,
      required this.value,
      required this.icon,
      required this.isPositive});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isPositive
                    ? Colors.greenAccent
                    : Colors.redAccent,
                size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _CategoryBar extends StatelessWidget {
  final TransactionCategory category;
  final double amount;
  final double total;
  const _CategoryBar(
      {required this.category,
      required this.amount,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        children: [
          Row(
            children: [
              Text(category.emoji,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  category.label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                DateFormatter.currency(amount),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: AppSizes.animNormal,
                  height: 6,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    gradient: AppColors.financeGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  const _TransactionTile(
      {required this.transaction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.priorityHigh),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (t.isExpense
                        ? AppColors.priorityHigh
                        : AppColors.financeStart)
                    .withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Center(
                child: Text(t.category.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${t.category.label} · ${DateFormatter.shortDate(t.date)}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${t.isExpense ? '-' : '+'}${DateFormatter.currency(t.amount)}',
              style: TextStyle(
                color: t.isExpense
                    ? AppColors.priorityHigh
                    : AppColors.financeStart,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTransactionSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddTransactionSheet({required this.ref});

  @override
  State<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TransactionCategory _category = TransactionCategory.food;
  bool _isExpense = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty || amount == null || amount <= 0) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: _isExpense ? _category : TransactionCategory.income,
      isExpense: _isExpense,
    );
    widget.ref.read(financeProvider.notifier).addTransaction(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXxl)),
        ),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (b) =>
                  AppColors.financeGradient.createShader(b),
              child: const Text(
                AppStrings.addTransaction,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            // Expense / Income toggle
            Row(
              children: [
                _TypeChip(
                  label: 'Expense',
                  selected: _isExpense,
                  color: AppColors.priorityHigh,
                  onTap: () => setState(() => _isExpense = true),
                ),
                const SizedBox(width: AppSizes.sm),
                _TypeChip(
                  label: 'Income',
                  selected: !_isExpense,
                  color: AppColors.financeStart,
                  onTap: () => setState(() => _isExpense = false),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _SheetField(
              controller: _titleCtrl,
              hint: 'Title',
              autofocus: true,
            ),
            const SizedBox(height: AppSizes.sm),
            _SheetField(
              controller: _amountCtrl,
              hint: 'Amount (₹)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            if (_isExpense) ...[
              const SizedBox(height: AppSizes.md),
              const Text('Category',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TransactionCategory.values
                    .where((c) => c != TransactionCategory.income)
                    .map((c) => GestureDetector(
                          onTap: () => setState(() => _category = c),
                          child: AnimatedContainer(
                            duration: AppSizes.animFast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _category == c
                                  ? AppColors.financeStart.withOpacity(0.2)
                                  : AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm),
                              border: Border.all(
                                color: _category == c
                                    ? AppColors.financeStart
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c.emoji,
                                    style:
                                        const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(c.label,
                                    style: TextStyle(
                                      color: _category == c
                                          ? AppColors.financeStart
                                          : AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.financeGradient,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: const Text(
                    AppStrings.save,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppSizes.animFast,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final TextInputType? keyboardType;
  const _SheetField(
      {required this.controller,
      required this.hint,
      this.autofocus = false,
      this.keyboardType});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textMuted, fontSize: 15),
          filled: true,
          fillColor: AppColors.surfaceHigh,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide:
                const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide:
                const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(
                color: AppColors.financeStart, width: 1.5),
          ),
        ),
      );
}
