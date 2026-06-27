import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const String _soundKey = 'aetherius_sound_enabled';
  static bool _enabled = true;
  
  static final AudioPlayer _playerLaser = AudioPlayer();
  static final AudioPlayer _playerExplosion = AudioPlayer();
  static final AudioPlayer _playerPowerUp = AudioPlayer();
  static final AudioPlayer _playerHit = AudioPlayer();
  static final AudioPlayer _playerLevelUp = AudioPlayer();

  static String? _laserPath;
  static String? _explosionPath;
  static String? _powerUpPath;
  static String? _hitPath;
  static String? _levelUpPath;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_soundKey) ?? true;

    try {
      final tempDir = await getTemporaryDirectory();
      
      final laserFile = File('${tempDir.path}/laser.wav');
      await laserFile.writeAsBytes(_getLaserBytes());
      _laserPath = laserFile.path;

      final explosionFile = File('${tempDir.path}/explosion.wav');
      await explosionFile.writeAsBytes(_getExplosionBytes());
      _explosionPath = explosionFile.path;

      final powerUpFile = File('${tempDir.path}/powerup.wav');
      await powerUpFile.writeAsBytes(_getPowerUpBytes());
      _powerUpPath = powerUpFile.path;

      final hitFile = File('${tempDir.path}/hit.wav');
      await hitFile.writeAsBytes(_getHitBytes());
      _hitPath = hitFile.path;

      final levelUpFile = File('${tempDir.path}/levelup.wav');
      await levelUpFile.writeAsBytes(_getLevelUpBytes());
      _levelUpPath = levelUpFile.path;
    } catch (e) {
      // Fallback if writing fails
    }
  }

  static bool get enabled => _enabled;

  static Future<void> toggleSound() async {
    _enabled = !_enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, _enabled);
  }

  static Uint8List _generateWavHeader(int numSamples, int sampleRate) {
    final header = Uint8List(44);
    final totalDataLen = numSamples + 36;
    
    // ChunkID
    header[0] = 0x52; // R
    header[1] = 0x49; // I
    header[2] = 0x46; // F
    header[3] = 0x46; // F
    
    // ChunkSize
    header[4] = (totalDataLen & 0xff);
    header[5] = ((totalDataLen >> 8) & 0xff);
    header[6] = ((totalDataLen >> 16) & 0xff);
    header[7] = ((totalDataLen >> 24) & 0xff);
    
    // Format
    header[8] = 0x57; // W
    header[9] = 0x41; // A
    header[10] = 0x56; // V
    header[11] = 0x45; // E
    
    // Subchunk1ID ("fmt ")
    header[12] = 0x66; // f
    header[13] = 0x6d; // m
    header[14] = 0x74; // t
    header[15] = 0x20; //  
    
    // Subchunk1Size
    header[16] = 16;
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    
    // AudioFormat (1 = PCM)
    header[20] = 1;
    header[21] = 0;
    
    // NumChannels (1 = Mono)
    header[22] = 1;
    header[23] = 0;
    
    // SampleRate
    header[24] = (sampleRate & 0xff);
    header[25] = ((sampleRate >> 8) & 0xff);
    header[26] = ((sampleRate >> 16) & 0xff);
    header[27] = ((sampleRate >> 24) & 0xff);
    
    // ByteRate = SampleRate * NumChannels * BitsPerSample/8
    final byteRate = sampleRate;
    header[28] = (byteRate & 0xff);
    header[29] = ((byteRate >> 8) & 0xff);
    header[30] = ((byteRate >> 16) & 0xff);
    header[31] = ((byteRate >> 24) & 0xff);
    
    // BlockAlign = NumChannels * BitsPerSample/8
    header[32] = 1;
    header[33] = 0;
    
    // BitsPerSample
    header[34] = 8;
    header[35] = 0;
    
    // Subchunk2ID ("data")
    header[36] = 0x64; // d
    header[37] = 0x61; // a
    header[38] = 0x74; // t
    header[39] = 0x61; // a
    
    // Subchunk2Size
    header[40] = (numSamples & 0xff);
    header[41] = ((numSamples >> 8) & 0xff);
    header[42] = ((numSamples >> 16) & 0xff);
    header[43] = ((numSamples >> 24) & 0xff);
    
    return header;
  }

  static Uint8List _getLaserBytes() {
    const sampleRate = 11025;
    const duration = 0.15;
    final numSamples = (sampleRate * duration).toInt();
    final data = Uint8List(44 + numSamples);
    data.setRange(0, 44, _generateWavHeader(numSamples, sampleRate));
    for (int i = 0; i < numSamples; i++) {
      final t = i / numSamples;
      final frequency = 800 - t * 600;
      final angle = 2 * math.pi * frequency * (i / sampleRate);
      final sample = (math.sin(angle) * 60 + 128).toInt().clamp(0, 255);
      data[44 + i] = sample;
    }
    return data;
  }

  static Uint8List _getExplosionBytes() {
    const sampleRate = 11025;
    const duration = 0.35;
    final numSamples = (sampleRate * duration).toInt();
    final data = Uint8List(44 + numSamples);
    data.setRange(0, 44, _generateWavHeader(numSamples, sampleRate));
    final random = math.Random();
    for (int i = 0; i < numSamples; i++) {
      final t = i / numSamples;
      final envelope = math.exp(-4 * t);
      final noise = random.nextDouble() * 2 - 1;
      final sample = (noise * envelope * 80 + 128).toInt().clamp(0, 255);
      data[44 + i] = sample;
    }
    return data;
  }

  static Uint8List _getPowerUpBytes() {
    const sampleRate = 11025;
    const duration = 0.3;
    final numSamples = (sampleRate * duration).toInt();
    final data = Uint8List(44 + numSamples);
    data.setRange(0, 44, _generateWavHeader(numSamples, sampleRate));
    for (int i = 0; i < numSamples; i++) {
      final t = i / numSamples;
      double freq = 300;
      if (t > 0.66) {
        freq = 600;
      } else if (t > 0.33) {
        freq = 450;
      }
      final angle = 2 * math.pi * freq * (i / sampleRate);
      final sampleVal = (angle % (2 * math.pi)) / (2 * math.pi);
      final val = sampleVal < 0.5 ? (sampleVal * 4 - 1) : (3 - sampleVal * 4);
      final sample = (val * 40 + 128).toInt().clamp(0, 255);
      data[44 + i] = sample;
    }
    return data;
  }

  static Uint8List _getHitBytes() {
    const sampleRate = 11025;
    const duration = 0.1;
    final numSamples = (sampleRate * duration).toInt();
    final data = Uint8List(44 + numSamples);
    data.setRange(0, 44, _generateWavHeader(numSamples, sampleRate));
    for (int i = 0; i < numSamples; i++) {
      final t = i / numSamples;
      final frequency = 120 + math.sin(t * 50) * 30;
      final angle = 2 * math.pi * frequency * (i / sampleRate);
      final val = angle % (2 * math.pi) < math.pi ? 1 : -1;
      final envelope = 1 - t;
      final sample = (val * envelope * 50 + 128).toInt().clamp(0, 255);
      data[44 + i] = sample;
    }
    return data;
  }

  static Uint8List _getLevelUpBytes() {
    const sampleRate = 11025;
    const duration = 0.5;
    final numSamples = (sampleRate * duration).toInt();
    final data = Uint8List(44 + numSamples);
    data.setRange(0, 44, _generateWavHeader(numSamples, sampleRate));
    for (int i = 0; i < numSamples; i++) {
      final t = i / numSamples;
      double freq = 261.63;
      if (t > 0.75) {
        freq = 523.25;
      } else if (t > 0.50) {
        freq = 392.00;
      } else if (t > 0.25) {
        freq = 329.63;
      }
      final angle = 2 * math.pi * freq * (i / sampleRate);
      final sampleVal = (angle % (2 * math.pi)) / (2 * math.pi);
      final val = sampleVal < 0.5 ? 1 : -1;
      final envelope = 1 - (t % 0.25) * 2;
      final sample = (val * envelope.clamp(0, 1) * 30 + 128).toInt().clamp(0, 255);
      data[44 + i] = sample;
    }
    return data;
  }

  static void playLaser() {
    if (!_enabled || _laserPath == null) return;
    _playerLaser.play(DeviceFileSource(_laserPath!));
  }

  static void playExplosion() {
    if (!_enabled || _explosionPath == null) return;
    _playerExplosion.play(DeviceFileSource(_explosionPath!));
  }

  static void playPowerUp() {
    if (!_enabled || _powerUpPath == null) return;
    _playerPowerUp.play(DeviceFileSource(_powerUpPath!));
  }

  static void playHit() {
    if (!_enabled || _hitPath == null) return;
    _playerHit.play(DeviceFileSource(_hitPath!));
  }

  static void playLevelUp() {
    if (!_enabled || _levelUpPath == null) return;
    _playerLevelUp.play(DeviceFileSource(_levelUpPath!));
  }
}
