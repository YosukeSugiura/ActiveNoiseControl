#  音声・インパルス応答データ

## 音声データ

- **cleaner.wav**

   掃除機騒音の音声wavデータ．  
   フィードフォワード制御のシミュレーションで使用．  
   - サンプリングレート：16k Hz  
   - チャンネル：モノラル
   - 量子化ビット幅：16bit
   
- **harmonics.wav**

   機械騒音＋狭帯域騒音の音声wavデータ．  
   フィードバック制御のシミュレーションで使用．
   - サンプリングレート：16k Hz  
   - チャンネル：モノラル
   - 量子化ビット幅：16bit
   
- **artificial_harmonic.wav**

   ```noise_maker.m```で人工的に生成した(白色雑音＋調波信号)の音声wavデータ．  
   ```noise_maker.m```でパラメータを変更可能．  
   フィードフォワード・フィードバック制御のどちらでもデバッグで使用可能．
   - サンプリングレート：16k Hz  
   - チャンネル：モノラル
   - 量子化ビット幅：16bit
   
## インパルス応答データ

- **impulse1.dat**

   １次経路のインパルス応答．
   
- **impulse2.dat**

   ２次経路のインパルス応答．
   
## 雑音生成ソースコード

- **noise_maker.m**
   
   (ガウス性白色雑音 + 複数正弦波)のwavデータを作成する．  
   正弦波の周波数や振幅等を指定できる．  
   ```artificial_harmonic.wav```を出力する．