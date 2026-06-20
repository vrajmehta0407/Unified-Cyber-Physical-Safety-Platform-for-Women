import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';

/// WebRTC Live Video Streaming Page
/// Streams victim's camera feed to police dashboard during SOS incident.
/// Uses WebRTC peer connection via your backend signaling server.
class LiveStreamPage extends StatefulWidget {
  final String incidentId;
  final bool isViewer; // false = victim streaming, true = police viewing

  const LiveStreamPage({
    super.key,
    required this.incidentId,
    this.isViewer = false,
  });

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  // WebRTC objects
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isFrontCamera = true;
  bool _isConnecting = false;
  String _statusText = 'Initializing...';
  Timer? _durationTimer;
  int _durationSeconds = 0;
  String? _error;

  // STUN/TURN configuration
  static const Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:your-turn-server.com:3478',
        'username': 'cybershield',
        'credential': 'changeme_in_production',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  static const Map<String, dynamic> _offerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
  };

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    setState(() => _statusText = 'Ready to stream');
    if (!widget.isViewer) {
      await _startStreaming();
    }
  }

  Future<void> _startStreaming() async {
    setState(() {
      _isConnecting = true;
      _statusText = 'Acquiring camera...';
    });

    try {
      // Get camera + mic stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'facingMode': _isFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': true,
      });
      _localRenderer.srcObject = _localStream;
      setState(() => _statusText = 'Camera acquired');

      // Create peer connection
      _peerConnection = await createPeerConnection(_iceConfig);

      // Add local stream tracks
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Handle remote stream (for viewer mode)
      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          setState(() => _remoteStream = event.streams[0]);
          _remoteRenderer.srcObject = _remoteStream;
        }
      };

      // ICE candidate handler
      _peerConnection!.onIceCandidate = (candidate) async {
        // Send ICE candidate to signaling server
        await _sendSignal({
          'type': 'ice_candidate',
          'incidentId': widget.incidentId,
          'candidate': candidate.toMap(),
        });
      };

      // Connection state
      _peerConnection!.onConnectionState = (state) {
        setState(() {
          switch (state) {
            case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
              _statusText = 'Streaming LIVE';
              _isConnecting = false;
              _isStreaming = true;
              _startDurationTimer();
              break;
            case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
              _statusText = 'Disconnected';
              _isStreaming = false;
              break;
            case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
              _statusText = 'Connection failed';
              _isStreaming = false;
              _isConnecting = false;
              break;
            default:
              break;
          }
        });
      };

      // Create offer and send to signaling server
      final offer = await _peerConnection!.createOffer(_offerConstraints);
      await _peerConnection!.setLocalDescription(offer);
      await _sendSignal({
        'type': 'offer',
        'incidentId': widget.incidentId,
        'sdp': offer.toMap(),
      });

      setState(() => _statusText = 'Connecting to police...');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isConnecting = false;
        _statusText = 'Error: $e';
      });
    }
  }

  Future<void> _sendSignal(Map<String, dynamic> signal) async {
    // Send to backend signaling endpoint
    // POST /sos/{incidentId}/webrtc/signal
    try {
      await ServiceLocator.instance.sos.sendWebRtcSignal(
        incidentId: widget.incidentId,
        signal: signal,
      );
    } catch (e) {
      debugPrint('[WebRTC] Signal send error: $e');
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _durationSeconds++);
    });
  }

  String get _durationDisplay {
    final m = (_durationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleMute() async {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !track.enabled;
    });
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _switchCamera() async {
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
      setState(() => _isFrontCamera = !_isFrontCamera);
    }
  }

  Future<void> _stopStream() async {
    _durationTimer?.cancel();
    _localStream?.getTracks().forEach((t) => t.stop());
    await _peerConnection?.close();
    setState(() {
      _isStreaming = false;
      _statusText = 'Stream ended';
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video feed
          if (_localStream != null)
            Positioned.fill(
              child: RTCVideoView(
                widget.isViewer ? _remoteRenderer : _localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: _isFrontCamera && !widget.isViewer,
              ),
            )
          else
            Container(
              color: const Color(0xFF0A0A1A),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.danger),
                    const SizedBox(height: 20),
                    Text(
                      _statusText,
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Dark overlay at top and bottom
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Live badge
                  if (_isStreaming)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE • $_durationDisplay',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _isConnecting ? 'Connecting...' : _statusText,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Incident ID
                  Text(
                    'INC-${widget.incidentId.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error display
          if (_error != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '⚠️ $_error',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute toggle
                    _StreamControl(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      onTap: _toggleMute,
                      color: _isMuted ? AppColors.warning : Colors.white,
                    ),

                    // Stop stream (red)
                    GestureDetector(
                      onTap: () async {
                        await _stopStream();
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.stop_rounded,
                            color: Colors.white, size: 34),
                      ),
                    ),

                    // Switch camera
                    _StreamControl(
                      icon: Icons.flip_camera_android_rounded,
                      label: 'Flip',
                      onTap: _switchCamera,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _StreamControl({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
