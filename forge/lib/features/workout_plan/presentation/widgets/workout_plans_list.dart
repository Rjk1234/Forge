import 'package:flutter/material.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_card.dart';

class WorkoutPlansList extends StatelessWidget {
  const WorkoutPlansList({
    required this.plans,
    required this.onPlanTap,
    super.key,
  });

  final List<WorkoutPlan> plans;
  final void Function(String planId) onPlanTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return PlanCard(plan: plan, onTap: () => onPlanTap(plan.id));
      },
    );
  }
}
