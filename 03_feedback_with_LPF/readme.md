# 線形予測器を用いたフィードバック制御シミュレーション
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/03_feedback_with_LPF/feedback_LPF_system.png" width="480px" />
   
   Matlab 2016 用ソースコード．シミュレートした環境は上図． 
   
   **Paper**：
   Feedback Active Noise Control using Linear Prediction Filter for Colored Wide-band Background Noise Environment  

   R. Takasugi, Y. Sugiura and T. Shimamura, "Feedback Active Noise Control using Linear Prediction Filter for Colored Wide-band Background Noise Environment," 2019 International Symposium on Intelligent Signal Processing and Communication Systems (ISPACS), 2019, pp. 1-2, doi: 10.1109/ISPACS48206.2019.8986340.
   
   Link : https://ieeexplore.ieee.org/document/8986340, Paper Link : [Accepted Version](http://133.38.201.199:50505/portal/apis/fileExplorer/download.cgi?act=download&link=JZUWlHty4JHu0IOzKNNbJQ&link_session_id=sjdfO7efBP-6YsQDTAjfgg00&total=1&browser=chrome&mod_cntype=1&path=%2FOpen&file=Feedback_Active_Noise_Control_using_Linear_Prediction_Filter_for_Colored_Wide-band_Background_Noise_Environment.pdf)
   
   
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

線形予測器を用いたフィードバック制御(FB-LPF-ANC)を行う．ただし，**２次経路は推定していない**．

### 使用コード

- **feedback_LPF_without_2ndpathEstimation.m**  

   ２次経路は既知として，２次経路モデルを<img src="https://latex.codecogs.com/png.latex?\dpi{120}&space;\hat{C}(z)=C(z)">と設定している． 
   
### 入力データ
   
   - **騒音データ**  
      00_data -> cleaner.wav  ： 掃除機騒音(狭帯域な騒音 + 広帯域な機械騒音)
      
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
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/03_feedback_with_LPF/result_fb.png">  
   
   *青線：ANC適用前の騒音, 赤線：ANC適用後の騒音*  
   
   波形からは騒音低減効果がわかりにくい．
   
   処理前と処理後における騒音のスペクトルグラムを下の図に示す．これらを比較すると，騒音に含まれる強い狭帯域騒音成分(約400Hz)が抑圧されていることがわかる．一方で，広帯域な騒音が残留していることがわかる．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/03_feedback_with_LPF/freq_in.png" width="520px" >

   入力騒音のスペクトログラム（横軸：時間，縦軸：周波数）
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/03_feedback_with_LPF/freq_fb.png" width="520px" > 

   騒音制御後のスペクトログラム（横軸：時間，縦軸：周波数）
   
* * * 
# 2. 線形予測器を用いたフィードバック制御 (2次経路は未知)

線形予測器を用いたフィードバック制御(FB-LPF-ANC)を行う．はじめにシステム同定法により２次経路を事前に推定する．

### 使用コード
- **feedback_LPF_with_2ndpathEstimation.m**  
   
### 入力データ
   
   - **騒音データ**  
      00_data -> harmonics.wav ： 狭帯域な騒音 + 広帯域な機械騒音
      
   - **２次経路のインパルス応答データ**  
      00_data -> impulse2.dat
    
   
### 設定パラメータ
   
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
   
### 実行結果
   
   実行結果は上記の２次経路を推定しないシステムとほぼ同一になるため省略する．
   
# 3. スペクトルの表示

### 使用コード
- **figure_plot.m**  

### 実行結果
   
   スペクトルを表示する(青色：制御前の騒音，赤色：FB-ANV，緑色：FB-LPF-ANC)．実行結果は以下の図の通り．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/03_feedback_with_LPF/spec.png">  

   騒音のスペクトル（横軸：周波数[Hz]，縦軸：パワー[dB]）

   この図からわかるように，