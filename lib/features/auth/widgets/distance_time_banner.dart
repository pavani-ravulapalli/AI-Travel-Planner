import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:travel_planner_app/features/map/provider/map_provider.dart';

///shows route info (distance + duration) when a route is active.
class DistanceTimeBanner extends ConsumerWidget{
  const DistanceTimeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    //watch both routeInfo and remaining fields
    final routeInfo = ref.watch(mapProvider.select((s) => s.routeInfo));
    final remainingDist = ref.watch(mapProvider.select((s) => s.remainingDistance),
    );
    final remainingDur = ref.watch(mapProvider.select((s)=> s.remainingDuration),
    );

    //use remaining if available, otherwise show total from routeInfo
    final distLabel = remainingDist.isNotEmpty
    ?remainingDist
        :routeInfo?.distance??'';
    final durlabel = remainingDur.isNotEmpty
    ?remainingDur
        :routeInfo?.duration??'';
    final panelTitle = remainingDist.isNotEmpty?'Remaining':'Total';
    if(routeInfo==null)return const SizedBox.shrink();

    return Positioned(
        bottom: 32,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(panelTitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoTile(
                    icon: Icons.route,
                    label:'Distance',
                    value: distLabel,
                  ),
                  Container(
                    width: 1,
                    height: 40, color: Colors.grey.shade200
                  ),
                  _InfoTile(
                    icon: Icons.access_time_rounded,
                    label: 'Duration',
                    value: durlabel,
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

class _InfoTile extends StatelessWidget{
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.value,
    required this.label,
    required this.icon,
});

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,color: Colors.blue,size: 22),
          const SizedBox(height: 4),
          Text(label,style: const TextStyle(color: Colors.grey,fontSize: 11)),
          Text(value,style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
    );
  }
}























