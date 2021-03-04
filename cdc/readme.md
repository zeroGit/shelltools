
用于保存一些常用的目录，可以快速选择跳转

cda 添加当前目录到缓存中
cdd 编辑缓存文件，删除添加目录
cdc 列出缓存文件中的所有目录，可以输入目录前面的序号跳转

```
chmod +x cd*
cp cd* /usr/local/bin/

mkdir /usr/local/lib/cdc
cp dealInput.py /usr/local/lib/cdc


echo "export PYTHONPATH=\$PYTHONPATH:/usr/local/lib/cdc" >> ~/.bashrc

echo "alias cdc='cdc_fun() { eval \$(cat ~/.cdcacheselect);}; cdcImp && cdc_fun'" >> ~/.bashrc

# then : . ~/.bashrc
```