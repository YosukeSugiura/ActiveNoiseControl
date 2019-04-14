# フィードフォワード制御   
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/image/feedforward_system.png" width="420px" />
   
   Matlab 2016 用ソースコードです．シミュレートした環境は上図（[詳細な説明はこちら](https://github.com/YosukeSugiura/ActiveNoiseControl/wiki/フィードフォワード型のシステムモデル)）．

* * * 
- **feedforward_without_2ndpassEstimation.m**  

   フィードフォワード制御を行う．ただし，**２次経路は推定しない**．２次経路は既知として，２次経路モデルを<img src="https://latex.codecogs.com/png.latex?\dpi{120}&space;\hat{C}(z)=C(z)">と設定している． 
   
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
   
   ## 実行結果
   
   実行した波形は以下の図の通り．
   入力騒音は機械動作音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/01_feedforward/result_ff1.png">  
   
   *青線：ANC適用前の騒音, 赤線：ANC適用後の騒音*  
   
   騒音が徐々に小さくなることが確認できる．
   
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
   図からある程度正確に２次経路を推定できていることがわかる．
   
   実行したは以下の図の通り．
   入力騒音は機械動作音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/01_feedforward/result_ff2.png">  
   
   - 青線：ANC適用前の騒音, 赤線：ANC適用後の騒音
   
   騒音が徐々に小さくなることが確認できる．
   ２次経路を既知とする場合と比べ，若干であるが収束が遅くなり，収束後の消音性能が劣化する．
