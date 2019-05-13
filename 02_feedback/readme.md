# フィードバック制御   
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/image/feedback_system.png" width="480px" />
   
   Matlab 2016 用ソースコードです．シミュレートした環境は上図（[詳細な説明はこちら](https://github.com/YosukeSugiura/ActiveNoiseControl/wiki/フィードフォワード型のシステムモデル)）．

* * * 
- **feedback_without_2ndpassEstimation.m**  

   フィードバック制御を行う．ただし，**２次経路は推定していない**．２次経路は既知として，２次経路モデルを<img src="https://latex.codecogs.com/png.latex?\dpi{120}&space;\hat{C}(z)=C(z)">と設定している． 
   
   ## 入力データ
   
   - **騒音データ**  
      00_data -> harmonics.wav  ： 狭帯域な騒音 + 広帯域な機械騒音
      
   - **２次経路のインパルス応答データ**  
      00_data -> impulse2.dat
    
   
   ## 設定パラメータ
   
   - **スピーカ・マイク間距離(cm)**  
      ２次経路の経路長(距離)を変更できる．  
      **１次経路は使用しない**．
      
   - **適応フィルタの次数**  
      騒音制御フィルタと二次経路モデルの次数を変更できる．  
      騒音制御フィルタのフィルタ次数は大きいほど消音性能が高まるが，計算量が増加する．
      また，次数が大きいと**動作が不安定になる**．
      
   - **適応フィルタの設定**   
      更新ステップサイズと平均化パラメータを変更できる．
      更新ステップサイズは大きいほど高速に動作するが，**安定性が著しく劣化する**場合がある．
   
   ## 実行結果
   
   実行した波形は以下の図の通り．
   入力騒音は狭帯域な騒音 + 広帯域な機械騒音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/result_fb1.png">  
   
   *青線：ANC適用前の騒音, 赤線：ANC適用後の騒音*  
   
   上の図から，騒音が抑圧されていることがわかる．
   さらに下の処理前と処理後における騒音のスペクトルグラムを比較すると，騒音に含まれる強い狭帯域騒音成分のみが抑圧され，広帯域な騒音が残留していることがわかる．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/freq_in1.png" width="480px" >

   入力騒音のスペクトルグラム（横軸：時間，縦軸：周波数）
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/02_feedback/freq_fb1.png" width="480px" > 

   騒音制御後のスペクトルグラム（横軸：時間，縦軸：周波数）
   
* * * 
- **feedforward_with_2ndpassEstimation.m**  

   フィードフォワード制御を行う．はじめにシステム同定法により２次経路を事前に推定する．
   
   ## 入力データ
   
   - **騒音データ**  
      00_data -> cleaner.wav  
      
   - **１次経路のインパルス応答データ**  
      00_data -> impulse1.dat
      
   - **２次経路のインパルス応答データ**  
      00_data -> impulse2.dat
    
   
   ## 設定パラメータ
   
   - **スピーカ・マイク間距離(cm)**  
      １次経路，２次経路の経路長(距離)を変更できる．
      
   - **適応フィルタの次数**  
      騒音制御フィルタと二次経路モデルの次数を変更できる．  
      騒音制御フィルタのフィルタ次数は大きいほど消音性能が高まるが，計算量と収束までの時間が増加する．
      
   - **適応フィルタの設定**   
      更新ステップサイズと平均化パラメータを変更できる．
      更新ステップサイズは大きいほど高速に動作するが，安定性と収束後の消音性能が劣化する．
    
   - **事前学習の時間**   
      事前学習（システム同定法）に費やす時間（サンプル長）を変更できる．
   
   ## 実行結果
   
   まずは事前推定した２次経路モデルのインパルス応答を下に示す．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/01_feedforward/result_2ndpath.png">  
   
   - 青線：２次経路のインパルス応答(真値), 赤線：２次経路モデル(推定値)
   
   ２次経路モデルのフィルタ次数は２次経路のインパルス応答長より短く設定している．
   図から２次経路モデルは２次経路をよく近似していることがわかる．
   
   実行したは以下の図の通り．
   入力騒音は機械動作音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/01_feedforward/result_ff2.png">  
   
   - 青線：ANC適用前の騒音, 赤線：ANC適用後の騒音
   
   騒音が徐々に小さくなることが確認できる．
