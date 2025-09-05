import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class PullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;
  final String? pullingText;
  final String? refreshingText;
  final Color? indicatorColor;
  final double triggerDistance;

  const PullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
    this.pullingText,
    this.refreshingText,
    this.indicatorColor,
    this.triggerDistance = 80.0,
  });

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.indicatorColor ?? Theme.of(context).primaryColor,
      strokeWidth: 3.0,
      displacement: widget.triggerDistance,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
            builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
              return _buildCustomRefreshIndicator(
                refreshState,
                pulledExtent,
                refreshTriggerPullDistance,
              );
            },
          ),
          SliverFillRemaining(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRefreshIndicator(
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
  ) {
    String text;
    IconData icon;
    Color color = widget.indicatorColor ?? Theme.of(context).primaryColor;

    switch (refreshState) {
      case RefreshIndicatorMode.inactive:
        text = widget.pullingText ?? 'Kéo để làm mới';
        icon = Icons.arrow_downward;
        break;
      case RefreshIndicatorMode.drag:
        final progress = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
        text = progress >= 1.0 
            ? (widget.refreshText ?? 'Thả để làm mới')
            : (widget.pullingText ?? 'Kéo để làm mới');
        icon = progress >= 1.0 ? Icons.refresh : Icons.arrow_downward;
        break;
      case RefreshIndicatorMode.armed:
        text = widget.refreshText ?? 'Thả để làm mới';
        icon = Icons.refresh;
        break;
      case RefreshIndicatorMode.refresh:
        text = widget.refreshingText ?? 'Đang làm mới...';
        icon = Icons.refresh;
        break;
      case RefreshIndicatorMode.done:
        text = 'Hoàn thành';
        icon = Icons.check;
        color = Colors.green;
        break;
    }

    return Container(
      height: pulledExtent,
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: pulledExtent > 20 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (refreshState == RefreshIndicatorMode.refresh)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              AnimatedRotation(
                turns: refreshState == RefreshIndicatorMode.armed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(icon, color: color, size: 20),
              ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _animationController.forward();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        _animationController.reverse();
      }
    }
  }
}

class SmartRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool enablePullToRefresh;
  final Duration autoRefreshInterval;
  final bool enableAutoRefresh;

  const SmartRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enablePullToRefresh = true,
    this.autoRefreshInterval = const Duration(minutes: 2),
    this.enableAutoRefresh = true,
  });

  @override
  State<SmartRefreshWrapper> createState() => _SmartRefreshWrapperState();
}

class _SmartRefreshWrapperState extends State<SmartRefreshWrapper>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;
  DateTime? _lastRefreshTime;
  bool _appInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableAutoRefresh) {
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _appInBackground = true;
        _autoRefreshTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
        if (_appInBackground) {
          _appInBackground = false;
          _handleAppResumed();
        }
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleAppResumed() {
    if (widget.enableAutoRefresh) {
      _startAutoRefresh();
    }

    // Refresh if app was in background for more than 5 minutes
    if (_lastRefreshTime != null && 
        DateTime.now().difference(_lastRefreshTime!).inMinutes > 5) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _performRefresh();
        }
      });
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (timer) {
      if (mounted && !_appInBackground) {
        _performRefresh();
      }
    });
  }

  Future<void> _performRefresh() async {
    _lastRefreshTime = DateTime.now();
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enablePullToRefresh) {
      return widget.child;
    }

    return PullToRefreshWidget(
      onRefresh: _performRefresh,
      refreshText: 'Thả để cập nhật menu',
      pullingText: 'Kéo để cập nhật menu',
      refreshingText: 'Đang cập nhật...',
      child: widget.child,
    );
  }
}

class RefreshableListView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const RefreshableListView({
    super.key,
    required this.children,
    required this.onRefresh,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return PullToRefreshWidget(
      onRefresh: onRefresh,
      child: ListView(
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        children: children,
      ),
    );
  }
}