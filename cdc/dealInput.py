#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys

class dealInput:
    
    def __init__(self) :
        pass

    # 以下函数 通过 topVar.oriStr = xxxx 组合成一条语句
    # 然后 执行 exec 上面那条语句

    def selectMapEle(self, oriStr, sMap, topVar) :
        # 获取 topVar 的名称
        litems = locals().items()
        for it in litems :
            if topVar == it[1] and it[0] != "item":
                topVarName = it[0]
                break
        execStr = topVarName + "." + oriStr

        while True:
            i = 0
            outStr = "> 选择 "
            outStr += oriStr
            outStr += "\n"
            for m in sMap :
                i += 1
                outStr += "  "
                outStr += str(i)
                outStr += ". "
                outStr += m
                outStr += "\n"
            outStr += "  0. Quit\n"
            outStr += "> "
            inS = raw_input(outStr)
            try:
                inI = int(inS)
            except:
                print "> 输入错误"
                continue
            else:
                pass

            # 检测输入结果
            if (inI == 0) :
                # quit
                return
            i = 0
            for m in sMap :
                i += 1
                if (i == inI) :
                    valueStr = sMap[m]
                    breakF = True
                    break
            if (breakF == True) :
                break
            print "> 输入错误 : 没有指定选项"

        execStr += " = " + inS
        
        print execStr
        exec(execStr)

    def inputStr(self, oriStr, topVar) :
        litems = locals().items()
        for it in litems :
            if topVar == it[1] and it[0] != "item":
                topVarName = it[0]
                break
        execStr = topVarName + "." + oriStr

        outStr = "> 请输入 "
        outStr += oriStr
        outStr += "\n> "
        inS = raw_input(outStr)
        if (len(inS) == 0) :
            print "  skip"
            return

        execStr += " = " + "\"" + inS + "\""
        
        print execStr
        exec(execStr)

    def inputInt(self, oriStr, topVar) :
        litems = locals().items()
        for it in litems :
            if topVar == it[1] and it[0] != "item":
                topVarName = it[0]
                break
        execStr = topVarName + "." + oriStr

        while True:
            outStr = "> 请输入 "
            outStr += oriStr
            outStr += "\n> "
            inS = raw_input(outStr)
            if (len(inS) == 0):
                print "  skip"
                return
            try:
                inI = int(inS)
            except:
                print "> 输入错误，请重新输入"
                continue
            break

        execStr += " = " + inS
        
        print execStr
        exec(execStr)
        
    # 不执行语句
    def selectListEle(self, oriStr, sList) :
        try:
            while True:
                i = 0
                outStr = "> 选择 \033[32;1m["
                outStr += oriStr
                outStr += "\033[0m] :\n"
                outStr += "] :\n"
                for m in sList :
                    i += 1
                    outStr += "  "
                    # if (i%2 == 0) :
                        # outStr += "\033[33;1m"
                    # else :
                        # outStr += "\033[36;1m"
                    outStr += str(i)
                    outStr += ". "
                    outStr += m
                    outStr += "\033[32;1m[" + str(i) + "]\033[0m"
                    # outStr += "\033[0m"
                    outStr += "\n"
                outStr += "  0. Quit\n"
                outStr += "> "
                inS = raw_input(outStr)
                try:
                    inI = int(inS)
                except:
                    print "> 输入错误"
                    continue
                else:
                    pass
                    
                # 检测输入结果
                if (inI == 0) :
                    # quit
                    return
                i = 0
                for m in sList :
                    i += 1
                    if (i == inI) :
                        valueStr = sList[i-1]
                        breakF = True
                        break
                if (breakF == True) :
                    break
                print "> 输入错误 : 没有指定选项"
            return valueStr
        except Exception as e:
            return 
    
def main() :
    pass

''' ---------------- 入口 ---------------- '''

if __name__ == "__main__":
    print "main"
    main()
else:
    #print "%s module" % __name__
	pass


