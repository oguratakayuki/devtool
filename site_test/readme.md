1. 変更前のhtmlをdataディレクトリに保管

ruby site_test.rb

2. デプロイしてコードの修正を反映

3. 以下のコマンドで変更後のhtmlを取得して、変更前のhtmlと比較する

ruby site_test.rb after

4. devまたはprodで環境を指定できます

ruby site_test.rb after dev

5. crawlingをしない場合

ruby site_test.rb after prod onlydiff
ruby site_test.rb after local onlydiff
