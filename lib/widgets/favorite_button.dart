import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorite_service.dart';

class FavoriteButton extends StatefulWidget {
  final Recipe recipe;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showAnimation;

  const FavoriteButton({
    super.key,
    required this.recipe,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.showAnimation = true,
  });

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    _favoriteService.toggleFavorite(widget.recipe);
    
    if (widget.showAnimation) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    // Show snackbar
    final isFavorite = _favoriteService.isFavorite(widget.recipe.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite 
              ? '${widget.recipe.title} ditambahkan ke favorite'
              : '${widget.recipe.title} dihapus dari favorite',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isFavorite ? Colors.green : Colors.grey,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            _favoriteService.toggleFavorite(widget.recipe);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _favoriteService,
      builder: (context, child) {
        final isFavorite = _favoriteService.isFavorite(widget.recipe.id);
        
        return widget.showAnimation
            ? AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildIconButton(isFavorite),
                  );
                },
              )
            : _buildIconButton(isFavorite);
      },
    );
  }

  Widget _buildIconButton(bool isFavorite) {
    return IconButton(
      onPressed: _toggleFavorite,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: widget.size,
        color: isFavorite
            ? (widget.activeColor ?? Colors.red)
            : (widget.inactiveColor ?? Colors.grey),
      ),
      tooltip: isFavorite ? 'Hapus dari favorite' : 'Tambah ke favorite',
    );
  }
}

// Widget untuk menampilkan jumlah favorite
class FavoriteCounter extends StatelessWidget {
  final TextStyle? textStyle;

  const FavoriteCounter({
    super.key,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteService(),
      builder: (context, child) {
        final count = FavoriteService().favoriteCount;
        return Text(
          '$count',
          style: textStyle ?? const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}