# 線形予測器を用いたフィードバック制御シミュレーション
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/03_feedback_with_LPF/feedback_LPF_system.png" width="480px" />
   
   Matlab 2016 用ソースコード．シミュレートした環境は上図． 
   
   **Paper**：
   Feedback Active Noise Control using Linear Prediction Filter for Colored Wide-band Background Noise Environment  

   R. Takasugi, Y. Sugiura and T. Shimamura, "Feedback Active Noise Control using Linear Prediction Filter for Colored Wide-band Background Noise Environment," 2019 International Symposium on Intelligent Signal Processing and Communication Systems (ISPACS), 2019, pp. 1-2, doi: 10.1109/ISPACS48206.2019.8986340.
   
   Link : https://ieeexplore.ieee.org/document/8986340, Paper Link : [Accepted Version]()
   
   
   > © 20XX IEEE. Personal use of this material is permitted. Permission from IEEE must be obtained for all other uses, in any current or future media, including reprinting/republishing this material for advertising or promotional purposes, creating new collective works, for resale or redistribution to servers or lists, or reuse of any copyrighted component of this work in other works.
   
   フィードバック能動騒音制御(FB-ANC)は周期騒音を制御するものである一方，ランダム性の強い騒音(=非周期騒音)を除去することができない．騒音に占める非周期成分が大きい場合，FB-ANCは不安定になることが知られている．本システムは，誤差信号に対して**線形予測器**を適用することで，制御対象である周期騒音のみを抽出し，制御信号を生成する．これにより，比較的安定なFB-ANCシステムを構築できる．
     
- **feedback_LPF_without_2ndpathEstimation.m**  
      2次経路を既知とした線形予測器を用いたFB-ANCシミュレーション
      
- **feedback_LPF_with_2ndpathEstimation.m**  
      2次経路を未知とした線形予測器を用いたFB-ANCシミュレーション

- **feedback_with_2ndpathEstimation.m**  
      従来のFB-ANC．2次経路は未知
          
- **figure_plot.m**  
      内部で`feedback_LPF_with_2ndpathEstimation.m`と`feedback_with_2ndpathEstimation.m`を実行し，出力音声のスペクトルを図示する．

- **stft_.m**  
      短時間フーリエ変換(STFT)を行うためのサブ関数．
      
* * * 
# 1. 線形予測器を用いたフィードバック制御 (2次経路は既知)

- 使用コード：**feedback_LPF_without_2ndpathEstimation.m**  

   線形予測器を用いたフィードバック制御を行う．ただし，**２次経路は推定していない**．２次経路は既知として，２次経路モデルを<img src="https://latex.codecogs.com/png.latex?\dpi{120}&space;\hat{C}(z)=C(z)">と設定している． 
   
   ### 入力データ
   
   - **騒音データ**  
      00_data -> cleaner.wav  ： 狭帯域な騒音 + 広帯域な機械騒音
      
   - **２次経路のインパルス応答データ**  
      00_data -> impulse2.dat
    
   
   ### 設定パラメータ
   
   - **スピーカ・マイク間距離(cm)**  
      ２次経路の経路長(距離)を変更できる．  **１次経路は使用しない**．
      
   - **適応フィルタの次数**  
   	- 騒音制御フィルタ
   	- 線形予測器  
      騒音制御フィルタのフィルタ次数は大きいほど消音性能が向上するが，計算量が増加する．
      線形予測器のフィルタ次数は大きいほど狭帯域騒音の抽出性能が向上するが，計算量が増加する．
      またどちらも，次数が大きいと**動作が不安定になる**．
      
   - **適応フィルタの設定** 
   	- 騒音制御フィルタ
   	- 線形予測器  
      更新ステップサイズと平均化パラメータを変更できる．
      更新ステップサイズは大きいほど高速に動作するが，**安定性が著しく劣化する**場合がある．
   
   ### 実行結果
   
   実行した波形は以下の図の通り．
   入力騒音は狭帯域な騒音 + 広帯域な機械騒音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/result_fb1.png">  
   
   *青線：ANC適用前の騒音, 赤線：ANC適用後の騒音*  
   
   上の図から，騒音が抑圧されていることがわかる．
   
   処理前と処理後における騒音のスペクトルグラムを下の図に示す．これらを比較すると，騒音に含まれる強い狭帯域騒音成分のみが抑圧され，広帯域な騒音が残留していることがわかる．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/freq_in1.png" width="520px" >

   入力騒音のスペクトルグラム（横軸：時間，縦軸：周波数）
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/freq_fb1.png" width="520px" > 

   騒音制御後のスペクトルグラム（横軸：時間，縦軸：周波数）
   
* * * 
- **feedback_LPF_with_2ndpathEstimation.m**  

   フィードバック制御を行う．はじめにシステム同定法により２次経路を事前に推定する．
   
   ## 入力データ
   
   - **騒音データ**  
      00_data -> harmonics.wav ： 狭帯域な騒音 + 広帯域な機械騒音
      
   - **２次経路のインパルス応答データ**  
      00_data -> impulse2.dat
    
   
   ## 設定パラメータ
   
   - **スピーカ・マイク間距離(cm)**  
      ２次経路の経路長(距離)を変更できる． **１次経路は使用しない**．
      
   - **適応フィルタの次数**  
   	- 騒音制御フィルタ
   	- 二次経路モデル
   	- 線形予測器  
      騒音制御フィルタのフィルタ次数は大きいほど消音性能が高まるが，計算量が増加する．
      線形予測器のフィルタ次数は大きいほど狭帯域騒音の抽出性能が向上するが，計算量が増加する．
      また，次数が大きいと**動作が不安定になる**．
      
   - **適応フィルタの設定**   
   	- 騒音制御フィルタ
   	- 二次経路モデル
   	- 線形予測器  
      更新ステップサイズと平均化パラメータを変更できる．
      更新ステップサイズは大きいほど高速に動作するが，**安定性が著しく劣化する**場合がある．
    
   - **事前学習の時間**   
      事前学習（システム同定法）に費やす時間（サンプル長）を変更できる．
   
   ## 実行結果
   
   まずは事前推定した２次経路モデルのインパルス応答を下に示す．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/01_feedforward/result_2ndpath.png">  
   
   - 青線：２次経路のインパルス応答(真値), 赤線：２次経路モデル(推定値)
   
   ２次経路モデルのフィルタ次数は２次経路のインパルス応答長より短く設定している．
   図から２次経路モデルは２次経路をよく近似していることがわかる．
   
   実行したは以下の図の通り．
   入力騒音は狭帯域な騒音 + 広帯域な機械騒音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/result_fb2.png">  
   
   - 青線：ANC適用前の騒音, 赤線：ANC適用後の騒音
   
   ２次経路を既知とした場合と同様，騒音が徐々に小さくなることが確認できる．
   
     さらに処理前と処理後における騒音のスペクトルグラムを下の図に示す．これらを比較すると，騒音に含まれる強い狭帯域騒音成分のみが抑圧され，広帯域な騒音が残留していることがわかる．２次経路を既知とした場合との差は僅かだが，２次経路の推定誤差による若干の騒音抑圧性能の劣化がある．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/freq_in1.png" width="520px" >

   入力騒音のスペクトルグラム（横軸：時間，縦軸：周波数）
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/freq_fb2.png" width="520px" > 

   騒音制御後のスペクトルグラム（横軸：時間，縦軸：周波数）

