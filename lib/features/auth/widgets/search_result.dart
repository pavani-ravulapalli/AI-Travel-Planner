import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner_app/features/map/model/place_result.dart';
import 'package:travel_planner_app/features/map/provider/map_provider.dart';
import 'package:flutter/material.dart';


class LocationSearchBar extends ConsumerStatefulWidget {
  const LocationSearchBar({super.key});

  @override
  ConsumerState<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends ConsumerState<LocationSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<PlaceResult> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value
        .trim()
        .isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      final results = await ref
          .read(placeServiceProvider)
          .getSuggestions(value);
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    });
    print("User typed:$value");
  }

  void _onSelect(PlaceResult place) {
    _controller.text = place.description;
    _focusNode.unfocus();
    setState(() => _suggestions = []);
    ref.read(mapProvider.notifier).selectDestination(place);
  }

  void clear() {
    _controller.clear();
    setState(() => _suggestions = []);
    ref.read(mapProvider.notifier).clearRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchField(
          controller: _controller,
          focusNode: _focusNode,
          loading: _loading,
          onChanged: _onChanged,
          onClear: clear,
        ),
        if(_suggestions.isNotEmpty)
          _SuggestionsList(suggestions: _suggestions, onSelect: _onSelect),
      ],
    );
  }
}

class _SearchField extends StatelessWidget{
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.focusNode,
    required this.controller,
    required this.loading,
    required this.onChanged,
    required this.onClear,
});

   @override
  Widget build(BuildContext context){
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(14),
         boxShadow: const [
           BoxShadow(color: Colors.black12,
           blurRadius: 12,
           offset: Offset(0, 4),
           ),
         ],
       ),
       child: TextField(
         controller: controller,
         focusNode: focusNode,
         onChanged: onChanged,
         decoration: InputDecoration(
           hintText: 'Search destination..',
           border: InputBorder.none,
           contentPadding: const EdgeInsets.symmetric(vertical: 14),
           prefixIcon: const Icon(Icons.search,color: Colors.grey),
           suffixIcon: loading?
               const Padding(padding: EdgeInsetsGeometry.all(12),
               child: SizedBox(
                 width: 20,
                 height: 20,
                 child: CircularProgressIndicator(strokeWidth: 2),
               ),
               ):controller.text.isNotEmpty
             ?IconButton(onPressed: onClear, icon: const Icon(Icons.clear))
               :null,
         ),
       ),
     );
   }
}
  class _SuggestionsList extends StatelessWidget {
    final List<PlaceResult> suggestions;
    final ValueChanged<PlaceResult> onSelect;

    const _SuggestionsList({required this.onSelect, required this.suggestions});


    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(top: 6),
        constraints: const BoxConstraints(maxHeight: 260),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 56),
          itemBuilder: (context, i) {
            final s = suggestions[i];
            return ListTile(
              leading: const Icon(Icons.location_on_outlined,
                color: Color(0xFF1A73E8),
              ),
              title: Text(s.primaryText,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: s.secondaryText.isNotEmpty
                  ? Text(s.secondaryText,
                style: const TextStyle(fontSize: 12,
                    color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
                  : null,
              onTap: () => onSelect(s),
            );
          },
        ),
      );
    }
  }
