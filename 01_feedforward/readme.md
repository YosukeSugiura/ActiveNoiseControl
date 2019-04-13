# フィードフォワード制御 

Matlab 2016 用ソースコードです．

- **feedforward20190411.m**  

   フィードフォワード制御を行う．シミュレートした環境は[こちら](https://github.com/YosukeSugiura/ActiveNoiseControl/wiki/フィードフォワード型のシステムモデル)．  
   ただし，**２次経路の推定はしていない**．２次経路は既知として，<img src="https://latex.codecogs.com/png.latex?\dpi{120}&space;\hat{C}(z)=C(z)">と設定している． 
   
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
   
   実行した結果は以下の図の通り．
   入力騒音は掃除機のモーター音である．
   
   <img src="https://github.com/YosukeSugiura/ActiveNoiseControl/blob/master/01_feedforward/result.png">  
   
   *青線：ANC適用前の騒音, 赤線：ANC適用後の騒音*  
