<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.StringReader" %>
<style>
 .header{
     color: #212529;
     font-size: 25.2px;
     font-family: Lato,Helvetica, sans-serif;
     border-bottom:1px solid #dddddd;

 }
 .subHeader{
     color: #212529;
     font-size: 14.4px;
     font-family: Lato,Helvetica, sans-serif;
     font-weight:600;
     border-bottom:1px solid #dddddd;
     height:40px;
 }
 .cell {
     color: #212529;
     font-size: 14.4px;
     font-family: Lato,Helvetica, sans-serif;
     border-bottom:1px solid #dddddd;
     height:30px;


 }

 <%
  String vars = "12,46334855,46334855,C,T,rs197758291,SNV,Rat/Rnor_6.0,\n" +
"12,46334878,46334878,C,T,rs198886146,SNV,Rat/Rnor_6.0,\n" +
"12,46335097,46335097,G,A,rs106165986,SNV,Rat/Rnor_6.0,\n" +
"12,46335228,46335228,A,C,rs106840596,SNV,Rat/Rnor_6.0,\n" +
"12,46335425,46335425,T,C,rs107382904,SNV,Rat/Rnor_6.0,\n" +
"12,46335967,46335967,A,G,rs197716245,SNV,Rat/Rnor_6.0,\n" +
"12,46336416,46336416,T,C,rs199026308,SNV,Rat/Rnor_6.0,\n" +
"12,46336794,46336794,G,C,rs197171374,SNV,Rat/Rnor_6.0,\n" +
"12,46336795,46336795,A,C,rs197992156,SNV,Rat/Rnor_6.0,\n" +
"12,46336877,46336877,C,T,rs198718315,SNV,Rat/Rnor_6.0,\n" +
"12,46337443,46337443,C,T,rs197111748,SNV,Rat/Rnor_6.0,\n" +
"12,46338133,46338133,G,A,rs105317699,SNV,Rat/Rnor_6.0,\n" +
"12,46338391,46338391,G,A,rs106911794,SNV,Rat/Rnor_6.0,\n" +
"12,46338579,46338579,G,A,rs199178661,SNV,Rat/Rnor_6.0,\n" +
"12,46339105,46339105,G,T,rs106970881,SNV,Rat/Rnor_6.0,\n" +
"12,46339233,46339233,A,C,rs105602317,SNV,Rat/Rnor_6.0,\n" +
"12,46340125,46340125,C,T,rs106702647,SNV,Rat/Rnor_6.0,\n" +
"12,46340880,46340880,T,C,rs105180818,SNV,Rat/Rnor_6.0,\n" +
"12,46341173,46341173,T,G,rs106604683,SNV,Rat/Rnor_6.0,\n" +
"12,46341181,46341181,T,G,rs105983104,SNV,Rat/Rnor_6.0,\n" +
"12,46341443,46341443,A,C,rs106275589,SNV,Rat/Rnor_6.0,\n" +
"12,46341446,46341446,A,G,rs106371410,SNV,Rat/Rnor_6.0,\n" +
"12,46341763,46341763,T,G,rs106820333,SNV,Rat/Rnor_6.0,\n" +
"12,46342114,46342114,A,G,rs106945198,SNV,Rat/Rnor_6.0,\n" +
"12,46342177,46342177,A,C,rs105712299,SNV,Rat/Rnor_6.0,\n" +
"12,46342290,46342290,A,G,rs107295594,SNV,Rat/Rnor_6.0,\n" +
"12,46342409,46342409,T,C,rs105188029,SNV,Rat/Rnor_6.0,\n" +
"12,46342449,46342449,A,G,rs197995884,SNV,Rat/Rnor_6.0,\n" +
"12,46342582,46342582,G,A,rs199021644,SNV,Rat/Rnor_6.0,\n" +
"12,46342711,46342711,A,C,rs106155636,SNV,Rat/Rnor_6.0,\n" +
"12,46343937,46343937,A,G,rs198069613,SNV,Rat/Rnor_6.0,\n" +
"12,46344325,46344325,T,C,rs199118622,SNV,Rat/Rnor_6.0,\n" +
"12,46344440,46344440,A,G,rs197498229,SNV,Rat/Rnor_6.0,\n" +
"12,46344693,46344693,A,C,rs198117644,SNV,Rat/Rnor_6.0,\n" +
"12,46345433,46345433,T,C,rs107148724,SNV,Rat/Rnor_6.0,\n" +
"12,46345979,46345979,T,C,rs105984012,SNV,Rat/Rnor_6.0,\n" +
"12,46346319,46346319,T,C,rs105866336,SNV,Rat/Rnor_6.0,\n" +
"12,46346566,46346566,G,A,rs107197441,SNV,Rat/Rnor_6.0,\n" +
"12,46347188,46347188,T,C,rs198211707,SNV,Rat/Rnor_6.0,\n" +
"12,46347251,46347251,T,C,rs198740401,SNV,Rat/Rnor_6.0,\n" +
"12,46347519,46347519,A,G,rs197768810,SNV,Rat/Rnor_6.0,\n" +
"12,46347684,46347684,C,G,rs105082531,SNV,Rat/Rnor_6.0,\n" +
"12,46347724,46347724,G,A,rs107314855,SNV,Rat/Rnor_6.0,\n" +
"12,46347965,46347965,C,T,rs106817542,SNV,Rat/Rnor_6.0,\n" +
"12,46348077,46348077,G,A,rs106447923,SNV,Rat/Rnor_6.0,\n" +
"12,46348132,46348132,T,C,rs107588080,SNV,Rat/Rnor_6.0,\n" +
"12,46348848,46348848,T,A,rs107281935,SNV,Rat/Rnor_6.0,\n" +
"12,46349022,46349022,T,G,rs106769500,SNV,Rat/Rnor_6.0,\n" +
"12,46349213,46349213,T,G,rs106855421,SNV,Rat/Rnor_6.0,\n" +
"12,46349694,46349694,A,G,rs106407722,SNV,Rat/Rnor_6.0,\n" +
"12,46350391,46350391,A,G,rs197239836,SNV,Rat/Rnor_6.0,\n" +
"12,46350412,46350412,C,T,rs198058980,SNV,Rat/Rnor_6.0,\n" +
"12,46353222,46353222,C,T,rs198529459,SNV,Rat/Rnor_6.0,\n" +
"12,46354141,46354141,A,G,rs198664579,SNV,Rat/Rnor_6.0,\n" +
"12,46354158,46354158,G,A,rs197347833,SNV,Rat/Rnor_6.0,\n" +
"12,46355864,46355864,T,C,rs198247166,SNV,Rat/Rnor_6.0,\n" +
"12,46357508,46357508,G,C,rs106999455,SNV,Rat/Rnor_6.0,\n" +
"12,46360297,46360297,A,G,rs197552564,SNV,Rat/Rnor_6.0,\n" +
"12,46360736,46360736,C,T,rs106889425,SNV,Rat/Rnor_6.0,\n" +
"12,46360895,46360895,T,C,rs198775009,SNV,Rat/Rnor_6.0,\n" +
"12,46361436,46361436,T,C,rs198806780,SNV,Rat/Rnor_6.0,\n" +
"12,46362711,46362711,T,C,rs197861643,SNV,Rat/Rnor_6.0,\n" +
"12,46365368,46365368,G,A,rs106024358,SNV,Rat/Rnor_6.0,\n" +
"12,46366387,46366387,T,C,rs197261773,SNV,Rat/Rnor_6.0,\n" +
"12,46366765,46366765,A,G,rs198491181,SNV,Rat/Rnor_6.0,\n" +
"12,46367354,46367354,C,T,rs105423859,SNV,Rat/Rnor_6.0,\n" +
"12,46367432,46367432,T,G,rs107557073,SNV,Rat/Rnor_6.0,\n" +
"12,46367815,46367815,C,T,rs105121210,SNV,Rat/Rnor_6.0,\n" +
"12,46368548,46368548,C,T,rs105968901,SNV,Rat/Rnor_6.0,\n" +
"12,46368653,46368653,C,T,rs105291434,SNV,Rat/Rnor_6.0,\n" +
"12,46369135,46369135,T,C,rs198582500,SNV,Rat/Rnor_6.0,\n" +
"12,46369492,46369492,G,A,rs106909882,SNV,Rat/Rnor_6.0,\n" +
"12,46369784,46369784,G,A,rs105615077,SNV,Rat/Rnor_6.0,\n" +
"12,46369805,46369805,T,C,rs105380829,SNV,Rat/Rnor_6.0,\n" +
"12,46370700,46370700,T,G,rs198107199,SNV,Rat/Rnor_6.0,\n" +
"12,46371834,46371834,G,A,rs106365295,SNV,Rat/Rnor_6.0,\n" +
"12,46372673,46372673,G,A,rs197755707,SNV,Rat/Rnor_6.0,\n" +
"12,46373118,46373118,A,G,rs105877068,SNV,Rat/Rnor_6.0,\n" +
"12,46373131,46373131,G,A,rs106498353,SNV,Rat/Rnor_6.0,\n" +
"12,46373226,46373226,G,A,rs107478367,SNV,Rat/Rnor_6.0,\n" +
"12,46373230,46373230,T,C,rs105297825,SNV,Rat/Rnor_6.0,\n" +
"12,46373257,46373257,C,T,rs106868642,SNV,Rat/Rnor_6.0,\n" +
"12,46373523,46373523,G,A,rs105191406,SNV,Rat/Rnor_6.0,\n" +
"12,46373986,46373986,T,C,rs107211477,SNV,Rat/Rnor_6.0,\n" +
"12,46373987,46373987,G,A,rs106162552,SNV,Rat/Rnor_6.0,\n" +
"12,46378502,46378502,G,C,rs107182117,SNV,Rat/Rnor_6.0,\n" +
"12,46378737,46378737,C,T,rs106362975,SNV,Rat/Rnor_6.0,\n" +
"12,46380020,46380020,G,A,rs106712462,SNV,Rat/Rnor_6.0,\n" +
"12,46388388,46388388,A,G,rs198390441,SNV,Rat/Rnor_6.0,\n" +
"12,46388606,46388606,G,A,rs197985918,SNV,Rat/Rnor_6.0,\n" +
"12,46388955,46388955,A,G,rs198332309,SNV,Rat/Rnor_6.0,\n" +
"12,46390422,46390422,G,A,rs106712584,SNV,Rat/Rnor_6.0,\n" +
"12,46391391,46391391,G,A,rs106760880,SNV,Rat/Rnor_6.0,\n" +
"12,46393881,46393881,T,G,rs197885397,SNV,Rat/Rnor_6.0,\n" +
"12,46394126,46394126,C,T,rs199249163,SNV,Rat/Rnor_6.0,\n" +
"12,46395389,46395389,C,G,rs105719610,SNV,Rat/Rnor_6.0,\n" +
"12,46395419,46395419,C,G,rs105694720,SNV,Rat/Rnor_6.0,\n" +
"12,46395423,46395423,C,G,rs106263400,SNV,Rat/Rnor_6.0,\n" +
"12,46395503,46395503,G,C,rs198317371,SNV,Rat/Rnor_6.0,\n" +
"12,46399641,46399641,T,C,rs107363459,SNV,Rat/Rnor_6.0,\n" +
"12,46400017,46400017,T,C,rs105767663,SNV,Rat/Rnor_6.0,\n" +
"12,46401797,46401797,T,C,rs105365986,SNV,Rat/Rnor_6.0,\n" +
"12,46402906,46402906,C,T,rs198687282,SNV,Rat/Rnor_6.0,\n" +
"12,46404468,46404468,A,G,rs105618233,SNV,Rat/Rnor_6.0,\n" +
"12,46404678,46404678,G,A,rs197553258,SNV,Rat/Rnor_6.0,\n" +
"12,46405245,46405245,T,C,rs107531569,SNV,Rat/Rnor_6.0,\n" +
"12,46405264,46405264,A,G,rs198097775,SNV,Rat/Rnor_6.0,\n" +
"12,46406364,46406364,C,A,rs105028117,SNV,Rat/Rnor_6.0,\n" +
"12,46406520,46406520,A,G,rs199408092,SNV,Rat/Rnor_6.0,\n" +
"12,46407524,46407524,G,A,rs197593165,SNV,Rat/Rnor_6.0,\n" +
"12,46408850,46408850,A,G,rs199119176,SNV,Rat/Rnor_6.0,\n" +
"12,46409728,46409728,G,A,rs106705329,SNV,Rat/Rnor_6.0,\n" +
"12,46410849,46410849,G,A,rs198840092,SNV,Rat/Rnor_6.0,\n" +
"12,46411052,46411052,A,G,rs197581414,SNV,Rat/Rnor_6.0,\n" +
"12,46411085,46411085,G,A,rs106930298,SNV,Rat/Rnor_6.0,\n" +
"12,46413239,46413239,C,G,rs198465496,SNV,Rat/Rnor_6.0,\n" +
"12,46414736,46414736,T,A,rs197008343,SNV,Rat/Rnor_6.0,\n" +
"12,46414846,46414846,A,G,rs107170335,SNV,Rat/Rnor_6.0,\n" +
"12,46415937,46415937,G,A,rs106848905,SNV,Rat/Rnor_6.0,\n" +
"12,46415943,46415943,C,G,rs105210372,SNV,Rat/Rnor_6.0,\n" +
"12,46416410,46416410,T,C,rs107267273,SNV,Rat/Rnor_6.0,\n" +
"12,46416504,46416504,G,A,rs65528624,SNV,Rat/Rnor_6.0,\n" +
"12,46416680,46416680,A,G,rs63903752,SNV,Rat/Rnor_6.0,\n" +
"12,46419028,46419028,T,C,rs198115727,SNV,Rat/Rnor_6.0,\n" +
"12,46419375,46419375,A,G,rs106848872,SNV,Rat/Rnor_6.0,\n" +
"12,46419585,46419585,C,T,rs106655881,SNV,Rat/Rnor_6.0,\n" +
"12,46419830,46419830,T,C,rs107177765,SNV,Rat/Rnor_6.0,\n" +
"12,46421302,46421302,C,T,rs198851622,SNV,Rat/Rnor_6.0,\n" +
"12,46423780,46423780,G,A,rs198856031,SNV,Rat/Rnor_6.0,\n" +
"12,46424533,46424533,T,A,rs105361280,SNV,Rat/Rnor_6.0,\n" +
"12,46424556,46424556,T,C,rs197767119,SNV,Rat/Rnor_6.0,\n" +
"12,46425279,46425279,A,G,rs198398175,SNV,Rat/Rnor_6.0,\n" +
"12,46425438,46425438,G,A,rs198926705,SNV,Rat/Rnor_6.0,\n" +
"12,46426064,46426064,T,C,rs106194743,SNV,Rat/Rnor_6.0,\n" +
"12,46426883,46426883,G,A,rs107118107,SNV,Rat/Rnor_6.0,\n" +
"12,46427338,46427338,G,A,rs107353432,SNV,Rat/Rnor_6.0,\n" +
"12,46427408,46427408,T,G,rs105890014,SNV,Rat/Rnor_6.0,\n" +
"12,46427939,46427939,T,C,rs197017607,SNV,Rat/Rnor_6.0,\n" +
"12,46427947,46427947,C,T,rs198342209,SNV,Rat/Rnor_6.0,\n" +
"12,46428230,46428230,T,C,rs197236476,SNV,Rat/Rnor_6.0,\n" +
"12,46428714,46428714,G,A,rs105899135,SNV,Rat/Rnor_6.0,\n" +
"12,46430321,46430321,G,A,rs197930424,SNV,Rat/Rnor_6.0,\n" +
"12,46431063,46431063,A,G,rs199137709,SNV,Rat/Rnor_6.0,\n" +
"12,46432057,46432057,C,T,rs197448547,SNV,Rat/Rnor_6.0,\n" +
"12,46432256,46432256,G,A,rs198121843,SNV,Rat/Rnor_6.0,\n" +
"12,46432258,46432258,C,A,rs198712326,SNV,Rat/Rnor_6.0,\n" +
"12,46434359,46434359,A,G,rs107365428,SNV,Rat/Rnor_6.0,\n" +
"12,46434436,46434436,A,G,rs107425656,SNV,Rat/Rnor_6.0,\n" +
"12,46434956,46434956,A,G,rs105586698,SNV,Rat/Rnor_6.0,\n" +
"12,46435344,46435344,T,C,rs106232647,SNV,Rat/Rnor_6.0,\n" +
"12,46435541,46435541,G,A,rs106285953,SNV,Rat/Rnor_6.0,\n" +
"12,46436147,46436147,C,A,rs107591643,SNV,Rat/Rnor_6.0,\n" +
"12,46437123,46437123,T,A,rs105486483,SNV,Rat/Rnor_6.0,\n" +
"12,46437363,46437363,T,C,rs107153681,SNV,Rat/Rnor_6.0,\n" +
"12,46437480,46437480,C,T,rs106831865,SNV,Rat/Rnor_6.0,\n" +
"12,46438865,46438865,A,G,rs106389206,SNV,Rat/Rnor_6.0,\n" +
"12,46439167,46439167,G,A,rs197254110,SNV,Rat/Rnor_6.0,\n" +
"12,46439957,46439957,A,G,rs105328698,SNV,Rat/Rnor_6.0,\n" +
"12,46440084,46440084,G,A,rs105784138,SNV,Rat/Rnor_6.0,\n" +
"12,46440127,46440127,G,A,rs105951841,SNV,Rat/Rnor_6.0,\n" +
"12,46440383,46440383,A,C,rs199085615,SNV,Rat/Rnor_6.0,\n" +
"12,46440384,46440384,C,A,rs197124384,SNV,Rat/Rnor_6.0,\n" +
"12,46440435,46440435,T,G,rs197984980,SNV,Rat/Rnor_6.0,\n" +
"12,46440444,46440444,A,C,rs198674218,SNV,Rat/Rnor_6.0,\n" +
"12,46441727,46441727,C,A,rs105195090,SNV,Rat/Rnor_6.0,\n" +
"12,46441789,46441789,G,A,rs197057997,SNV,Rat/Rnor_6.0,\n" +
"12,46441943,46441943,T,A,rs107360476,SNV,Rat/Rnor_6.0,\n" +
"12,46445354,46445354,A,G,rs198628456,SNV,Rat/Rnor_6.0,\n" +
"12,46447182,46447182,G,A,rs107034519,SNV,Rat/Rnor_6.0,\n" +
"12,46449063,46449063,T,C,rs197528346,SNV,Rat/Rnor_6.0,\n" +
"12,46449271,46449271,A,T,rs198215899,SNV,Rat/Rnor_6.0,\n" +
"12,46449282,46449282,C,A,rs199133227,SNV,Rat/Rnor_6.0,\n" +
"12,46449490,46449490,A,G,rs106471012,SNV,Rat/Rnor_6.0,\n" +
"12,46449516,46449516,C,A,rs107139661,SNV,Rat/Rnor_6.0,\n" +
"12,46450408,46450408,A,G,rs105630870,SNV,Rat/Rnor_6.0,\n" +
"12,46451335,46451335,G,T,rs106604481,SNV,Rat/Rnor_6.0,\n" +
"12,46452529,46452529,A,G,rs198838903,SNV,Rat/Rnor_6.0,\n" +
"12,46453675,46453675,A,G,rs199296721,SNV,Rat/Rnor_6.0,\n" +
"12,46453807,46453807,T,G,rs199027060,SNV,Rat/Rnor_6.0,\n" +
"12,46455350,46455350,C,T,rs106075991,SNV,Rat/Rnor_6.0,\n" +
"12,46455881,46455881,A,G,rs107387128,SNV,Rat/Rnor_6.0,\n" +
"12,46455887,46455887,G,A,rs106181059,SNV,Rat/Rnor_6.0,\n" +
"12,46455892,46455892,G,A,rs197773517,SNV,Rat/Rnor_6.0,\n" +
"12,46458013,46458013,G,T,rs107497771,SNV,Rat/Rnor_6.0,\n" +
"12,46459186,46459186,G,C,rs199020676,SNV,Rat/Rnor_6.0,\n" +
"12,46459268,46459268,A,G,rs105592049,SNV,Rat/Rnor_6.0,\n" +
"12,46459392,46459392,C,A,rs197979115,SNV,Rat/Rnor_6.0,\n" +
"12,46460027,46460027,A,G,rs106556960,SNV,Rat/Rnor_6.0,\n" +
"12,46460086,46460086,A,C,rs198327607,SNV,Rat/Rnor_6.0,\n" +
"12,46460348,46460348,C,T,rs105825105,SNV,Rat/Rnor_6.0,\n" +
"12,46463089,46463089,A,G,rs197090040,SNV,Rat/Rnor_6.0,\n" +
"12,46463511,46463511,G,A,,SNV,Rat/Rnor_6.0,nonsynonymous,probably damaging\n" +
"12,46464176,46464176,T,A,rs63854586,SNV,Rat/Rnor_6.0,\n" +
"12,46464381,46464381,T,C,rs198669689,SNV,Rat/Rnor_6.0,\n" +
"12,46464650,46464650,C,T,rs198020391,SNV,Rat/Rnor_6.0,\n" +
"12,46464738,46464738,C,T,rs199194210,SNV,Rat/Rnor_6.0,\n" +
"12,46465246,46465246,G,A,rs197599711,SNV,Rat/Rnor_6.0,\n" +
"12,46465902,46465902,G,A,rs65299179,SNV,Rat/Rnor_6.0,\n" +
"12,46465971,46465971,G,A,rs65101615,SNV,Rat/Rnor_6.0,\n" +
"12,46466932,46466932,A,G,rs104987188,SNV,Rat/Rnor_6.0,\n" +
"12,46467754,46467754,A,T,rs198664004,SNV,Rat/Rnor_6.0,\n" +
"12,46468709,46468709,T,C,rs198932450,SNV,Rat/Rnor_6.0,\n" +
"12,46468758,46468758,G,A,rs197730702,SNV,Rat/Rnor_6.0,\n" +
"12,46469110,46469110,G,A,rs198492975,SNV,Rat/Rnor_6.0,\n" +
"12,46469279,46469279,A,G,rs197579337,SNV,Rat/Rnor_6.0,\n" +
"12,46469306,46469306,T,C,rs198464480,SNV,Rat/Rnor_6.0,\n" +
"12,46469397,46469397,T,C,rs196997910,SNV,Rat/Rnor_6.0,\n" +
"12,46469983,46469983,C,T,rs105069931,SNV,Rat/Rnor_6.0,\n" +
"12,46470410,46470410,A,G,rs199015281,SNV,Rat/Rnor_6.0,\n" +
"12,46470737,46470737,C,T,rs197241615,SNV,Rat/Rnor_6.0,\n" +
"12,46470755,46470755,G,A,rs198043098,SNV,Rat/Rnor_6.0,\n" +
"12,46471029,46471029,T,C,rs198113329,SNV,Rat/Rnor_6.0,\n" +
"12,46471260,46471260,A,G,rs105154058,SNV,Rat/Rnor_6.0,\n" +
"12,46471429,46471429,A,G,rs105564636,SNV,Rat/Rnor_6.0,\n" +
"12,46471638,46471638,G,A,rs106448184,SNV,Rat/Rnor_6.0,\n" +
"12,46471794,46471794,A,T,rs197274291,SNV,Rat/Rnor_6.0,\n" +
"12,46471821,46471821,C,T,rs104960880,SNV,Rat/Rnor_6.0,\n" +
"12,46471885,46471885,G,A,rs104945056,SNV,Rat/Rnor_6.0,\n" +
"12,46472631,46472631,A,G,rs105552602,SNV,Rat/Rnor_6.0,\n" +
"12,46472774,46472774,G,A,rs105221739,SNV,Rat/Rnor_6.0,\n" +
"12,46473268,46473268,C,T,rs198924752,SNV,Rat/Rnor_6.0,\n" +
"12,46473781,46473781,C,T,rs197723166,SNV,Rat/Rnor_6.0,\n" +
"12,46474001,46474001,G,A,rs197116691,SNV,Rat/Rnor_6.0,\n" +
"12,46474711,46474711,G,A,rs197522053,SNV,Rat/Rnor_6.0,\n" +
"12,46475027,46475027,A,G,rs199080224,SNV,Rat/Rnor_6.0,\n" +
"12,46475053,46475053,A,G,rs107029373,SNV,Rat/Rnor_6.0,\n" +
"12,46475718,46475718,C,T,rs105317842,SNV,Rat/Rnor_6.0,\n" +
"12,46475727,46475727,T,C,rs199178778,SNV,Rat/Rnor_6.0,\n" +
"12,46475939,46475939,G,C,rs107543038,SNV,Rat/Rnor_6.0,\n" +
"12,46476119,46476119,T,G,rs107564714,SNV,Rat/Rnor_6.0,\n" +
"12,46476237,46476237,G,A,rs198519631,SNV,Rat/Rnor_6.0,\n" +
"12,46476433,46476433,C,A,rs197508201,SNV,Rat/Rnor_6.0,\n" +
"12,46476493,46476493,A,T,rs198705044,SNV,Rat/Rnor_6.0,\n" +
"12,46476570,46476570,C,T,rs197335433,SNV,Rat/Rnor_6.0,\n" +
"12,46476755,46476755,C,T,rs198290278,SNV,Rat/Rnor_6.0,\n" +
"12,46476806,46476806,A,G,rs198843760,SNV,Rat/Rnor_6.0,\n" +
"12,46476866,46476866,G,A,rs197537304,SNV,Rat/Rnor_6.0,\n" +
"12,46477000,46477000,G,A,rs198756848,SNV,Rat/Rnor_6.0,\n" +
"12,46477010,46477010,C,T,rs198798393,SNV,Rat/Rnor_6.0,\n" +
"12,46477116,46477116,G,A,rs197781158,SNV,Rat/Rnor_6.0,\n" +
"12,46477315,46477315,T,G,rs106689864,SNV,Rat/Rnor_6.0,\n" +
"12,46477653,46477653,C,A,rs197333476,SNV,Rat/Rnor_6.0,\n" +
"12,46477745,46477745,G,C,rs197107193,SNV,Rat/Rnor_6.0,\n" +
"12,46477880,46477880,G,A,rs197881914,SNV,Rat/Rnor_6.0,\n" +
"12,46478112,46478112,T,C,rs199247237,SNV,Rat/Rnor_6.0,\n" +
"12,46478227,46478227,A,C,rs197070078,SNV,Rat/Rnor_6.0,\n" +
"12,46478265,46478265,G,A,rs198311260,SNV,Rat/Rnor_6.0,\n" +
"12,46478337,46478337,G,A,rs198625327,SNV,Rat/Rnor_6.0,\n" +
"12,46478964,46478964,A,G,rs105411604,SNV,Rat/Rnor_6.0,\n" +
"12,46479126,46479126,C,G,rs105974722,SNV,Rat/Rnor_6.0,\n" +
"12,46479324,46479324,T,C,rs106614423,SNV,Rat/Rnor_6.0,\n" +
"12,46479706,46479706,C,T,rs106801112,SNV,Rat/Rnor_6.0,\n" +
"12,46480033,46480033,C,T,rs105107799,SNV,Rat/Rnor_6.0,\n" +
"12,46480111,46480111,G,A,rs107537732,SNV,Rat/Rnor_6.0,\n" +
"12,46480260,46480260,A,G,rs106200908,SNV,Rat/Rnor_6.0,\n" +
"12,46480546,46480546,A,G,rs106394418,SNV,Rat/Rnor_6.0,\n" +
"12,46480616,46480616,T,C,rs107222349,SNV,Rat/Rnor_6.0,\n" +
"12,46481027,46481027,G,A,rs198792933,SNV,Rat/Rnor_6.0,\n" +
"12,46481193,46481193,C,T,rs197858345,SNV,Rat/Rnor_6.0,\n" +
"12,46481375,46481375,A,G,rs106463924,SNV,Rat/Rnor_6.0,\n" +
"12,46481608,46481608,A,C,rs197242498,SNV,Rat/Rnor_6.0,\n" +
"12,46481678,46481678,A,G,rs198326081,SNV,Rat/Rnor_6.0,\n" +
"12,46481923,46481923,G,A,rs197079356,SNV,Rat/Rnor_6.0,\n" +
"12,46481959,46481959,T,C,rs197911599,SNV,Rat/Rnor_6.0,\n" +
"12,46482030,46482030,A,G,rs198664440,SNV,Rat/Rnor_6.0,\n" +
"12,46482036,46482036,A,G,rs197329503,SNV,Rat/Rnor_6.0,\n" +
"12,46482060,46482060,G,A,rs198511059,SNV,Rat/Rnor_6.0,\n" +
"12,46482071,46482071,A,G,rs198622209,SNV,Rat/Rnor_6.0,\n" +
"12,46482116,46482116,G,A,rs197293199,SNV,Rat/Rnor_6.0,\n" +
"12,46482138,46482138,A,G,rs105701952,SNV,Rat/Rnor_6.0,\n" +
"12,46482216,46482216,A,G,rs106114015,SNV,Rat/Rnor_6.0,\n" +
"12,46482308,46482308,C,T,rs198572601,SNV,Rat/Rnor_6.0,\n" +
"12,46482309,46482309,A,G,rs107558743,SNV,Rat/Rnor_6.0,\n" +
"12,46482412,46482412,G,A,rs105449914,SNV,Rat/Rnor_6.0,\n" +
"12,46482507,46482507,G,T,rs106038013,SNV,Rat/Rnor_6.0,\n" +
"12,46482549,46482549,C,A,rs107362673,SNV,Rat/Rnor_6.0,\n" +
"12,46482678,46482678,T,C,rs106360059,SNV,Rat/Rnor_6.0,\n" +
"12,46482873,46482873,A,G,rs107364557,SNV,Rat/Rnor_6.0,\n" +
"12,46483022,46483022,T,A,rs107379541,SNV,Rat/Rnor_6.0,\n" +
"12,46483148,46483148,C,T,rs198063805,SNV,Rat/Rnor_6.0,\n" +
"12,46483282,46483282,G,A,rs198422676,SNV,Rat/Rnor_6.0,\n" +
"12,46483424,46483424,T,C,rs197994681,SNV,Rat/Rnor_6.0,\n" +
"12,46483456,46483456,C,T,rs199136270,SNV,Rat/Rnor_6.0,\n" +
"12,46483525,46483525,A,C,rs197553502,SNV,Rat/Rnor_6.0,\n" +
"12,46484308,46484308,A,G,rs198101143,SNV,Rat/Rnor_6.0,\n" +
"12,46484374,46484374,C,T,rs199229729,SNV,Rat/Rnor_6.0,\n" +
"12,46484434,46484434,G,A,rs197428752,SNV,Rat/Rnor_6.0,\n" +
"12,46484451,46484451,T,G,rs198851205,SNV,Rat/Rnor_6.0,\n" +
"12,46484476,46484476,G,A,rs198611744,SNV,Rat/Rnor_6.0,\n" +
"12,46484493,46484493,T,G,rs197277076,SNV,Rat/Rnor_6.0,\n" +
"12,46485049,46485049,A,G,rs107293504,SNV,Rat/Rnor_6.0,\n" +
"12,46485217,46485217,G,A,rs106408575,SNV,Rat/Rnor_6.0,\n" +
"12,46485453,46485453,G,A,rs104920824,SNV,Rat/Rnor_6.0,\n" +
"12,46485472,46485472,G,T,rs106490934,SNV,Rat/Rnor_6.0,\n" +
"12,46485503,46485503,G,A,rs106386757,SNV,Rat/Rnor_6.0,\n" +
"12,46486688,46486688,T,C,rs105027311,SNV,Rat/Rnor_6.0,\n" +
"12,46487024,46487024,T,C,rs197679159,SNV,Rat/Rnor_6.0,\n" +
"12,46487269,46487269,A,C,rs198988346,SNV,Rat/Rnor_6.0,\n" +
"12,46487457,46487457,G,A,rs197114582,SNV,Rat/Rnor_6.0,\n" +
"12,46487614,46487614,A,G,rs197654367,SNV,Rat/Rnor_6.0,\n" +
"12,46487693,46487693,A,G,rs198457491,SNV,Rat/Rnor_6.0,\n" +
"12,46487751,46487751,A,T,rs105241769,SNV,Rat/Rnor_6.0,\n" +
"12,46487839,46487839,G,A,rs198335814,SNV,Rat/Rnor_6.0,\n" +
"12,46487863,46487863,C,T,rs105139294,SNV,Rat/Rnor_6.0,\n" +
"12,46487869,46487869,G,A,rs105927520,SNV,Rat/Rnor_6.0,\n" +
"12,46487972,46487972,C,T,rs105235114,SNV,Rat/Rnor_6.0,\n" +
"12,46488033,46488033,C,A,rs105967865,SNV,Rat/Rnor_6.0,\n" +
"12,46488114,46488114,A,G,rs105639906,SNV,Rat/Rnor_6.0,\n" +
"12,46488122,46488122,C,G,rs106399449,SNV,Rat/Rnor_6.0,\n" +
"12,46488420,46488420,A,G,rs107357086,SNV,Rat/Rnor_6.0,\n" +
"12,46488840,46488840,C,G,rs198282921,SNV,Rat/Rnor_6.0,\n" +
"12,46489267,46489267,T,C,rs107559473,SNV,Rat/Rnor_6.0,\n" +
"12,46490257,46490257,C,G,rs106104053,SNV,Rat/Rnor_6.0,\n" +
"12,46490293,46490293,C,A,rs105569246,SNV,Rat/Rnor_6.0,\n" +
"12,46490300,46490300,T,G,rs105614725,SNV,Rat/Rnor_6.0,\n" +
"12,46490314,46490314,C,T,rs107217052,SNV,Rat/Rnor_6.0,\n" +
"12,46490495,46490495,T,C,rs105153258,SNV,Rat/Rnor_6.0,\n" +
"12,46490519,46490519,C,T,rs197331857,SNV,Rat/Rnor_6.0,\n" +
"12,46490601,46490601,C,T,rs104967383,SNV,Rat/Rnor_6.0,\n" +
"12,46490730,46490730,A,C,rs105322335,SNV,Rat/Rnor_6.0,\n" +
"12,46490946,46490946,T,C,rs106965919,SNV,Rat/Rnor_6.0,\n" +
"12,46490955,46490955,C,A,rs106385518,SNV,Rat/Rnor_6.0,\n" +
"12,46491238,46491238,A,T,rs106626193,SNV,Rat/Rnor_6.0,\n" +
"12,46491679,46491679,C,T,rs198672384,SNV,Rat/Rnor_6.0,\n" +
"12,46492011,46492011,A,C,rs105367034,SNV,Rat/Rnor_6.0,\n" +
"12,46492189,46492189,G,A,rs105536401,SNV,Rat/Rnor_6.0,\n" +
"12,46492326,46492326,G,A,rs197275688,SNV,Rat/Rnor_6.0,\n" +
"12,46492364,46492364,G,T,rs198003643,SNV,Rat/Rnor_6.0,\n" +
"12,46492393,46492393,G,C,rs198575034,SNV,Rat/Rnor_6.0,\n" +
"12,46492533,46492533,A,G,rs197427889,SNV,Rat/Rnor_6.0,\n" +
"12,46492553,46492553,G,A,rs198675114,SNV,Rat/Rnor_6.0,\n" +
"12,46492559,46492559,C,G,rs198931637,SNV,Rat/Rnor_6.0,\n" +
"12,46493065,46493065,T,A,rs197419822,SNV,Rat/Rnor_6.0,\n" +
"12,46493237,46493237,G,A,rs105000227,SNV,Rat/Rnor_6.0,\n" +
"12,46493475,46493475,T,G,rs105831465,SNV,Rat/Rnor_6.0,\n" +
"12,46493593,46493593,C,T,rs199326396,SNV,Rat/Rnor_6.0,\n" +
"12,46493665,46493665,A,G,rs199054910,SNV,Rat/Rnor_6.0,\n" +
"12,46493669,46493669,C,A,rs199257001,SNV,Rat/Rnor_6.0,\n" +
"12,46493812,46493812,A,C,rs197768409,SNV,Rat/Rnor_6.0,\n" +
"12,46493987,46493987,A,G,rs106452346,SNV,Rat/Rnor_6.0,\n" +
"12,46493042,46493042,C,-,,deletion,Rat/Rnor,";
%>
</style>

<table>
    <tr>
        <td colspan="2"><img src="top.png"/></td>
    </tr>
    <tr>
        <td valign="top">
            <img src="left.png"/>
        </td>
        <td>
            <table>
                <tr>
                    <td>

                        <table width="100%" cellpadding="0" cellspacing="0">
                            <tr style="border:1px solid black;">
                                <td class="header" >NC_005111.4:g.46493042_46493042del</td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td class="subHeader" width="300">Species</td>
                                            <td class="cell">Rattus norvegicus</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Variant Type</td>
                                            <td class="cell">deletion</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">HGVS Name</td>
                                            <td class="cell">NC....</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Location</td>
                                            <td class="cell">Genic</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Chromosome</td>
                                            <td class="cell">12</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Start</td>
                                            <td class="cell">46,463,511</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Stop</td>
                                            <td class="cell">46,463,511</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Reference Nucleotide</td>
                                            <td class="cell">G</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Nucleotide Change</td>
                                            <td class="cell">-</td>
                                        <tr>
                                            <td class="subHeader" width="300">Most Severe Consequence</td>
                                            <td class="cell">frameshift</td>
                                        </tr>
                                        <tr>
                                            <td class="subHeader" width="300">Most Severe Protein Consequence</td>
                                            <td class="cell">Probably Damaging</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>

                    </td>
                </tr>
                <tr>
                    <td><br><br><img src="variants.png"/></td>
                </tr>
                <tr>

                <tr>
                    <td>
                        <table cellpadding="5" cellspacin="5" width="100%">
                            <tr style="border:1px solid black;">
                                <td class="header" colspan="3"><br>Variant Sources</td>
                            </tr>
                            <tr>
                                <td class="cell">European Variant Archive (EVA)</td>
                            </tr>
                            <tr>
                                <td class="cell">F344/NCrl - Whole Genome Sequence</td>
                            </tr>
                            <tr>
                                <td class="cell">F344/NRrrc - Whole Genome Sequence</td>
                            </tr>
                        </table>
                        <br>
                    </td>

                </tr>


                <tr>
                    <td>
                        <table width="100%" cellpadding="0" cellspacin="0">
                            <tr style="border:1px solid black;">
                                <td class="header" ><br>Related Genes</td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%"  cellpadding="0" cellspacin="0">
                                        <tr>
                                            <td class="subHeader">Species</td>
                                            <td class="subHeader">Symbol</td>
                                            <td class="subHeader"></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Rattus Norvegicus</td>
                                            <td class="cell"><a href="../../ratGene">Cit</a></td>
                                            <td class="cell"><a href="../variantList">Browse Variants</a></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Homo sapiens</td>
                                            <td class="cell"><a href="../../humanGene">CIT</a></td>
                                            <td class="cell"><a href="../../humanGene/variantList">Browse Orhtolog Variants</a></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Mus musculus</td>
                                            <td class="cell"><a href="../../ratGene">Cit</a></td>
                                            <td class="cell"><a href="../variantList">Browse Ortholog Variants</a></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Danio rerio</td>
                                            <td class="cell"><a href="../../ratGene">cita</a></td>
                                            <td class="cell"><a href="../variantList">Browse Ortholog Variants</a></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Drosophila melanogaster</td>
                                            <td class="cell"><a href="../../ratGene">sti</a></td>
                                            <td class="cell"><a href="../variantList">Browse Ortholog Variants</a></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Caenorhabditis elegans</td>
                                            <td class="cell"><a href="../../ratGene">F59A6.5</a></td>
                                            <td class="cell"><a href="../variantList">Browse Ortholog Variants</a></td>
                                        </tr>
                                        <tr>
                                            <td class="cell">Caenorhabditis elegans</td>
                                            <td class="cell"><a href="../../ratGene">W02B8.2</a></td>
                                            <td class="cell"><a href="../variantList">Browse Ortholog Variants</a></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>



                <tr>
                    <td>
                        <table width="100%" cellpadding="0" cellspacin="0">
                            <tr style="border:1px solid black;">
                                <td class="header" ><br>Related Gene Alleles</td>
                            </tr>
                            <tr>
                                <td>
                                <table width="100%"  cellpadding="0" cellspacin="0">
                                    <tr>
                                        <td class="subHeader">Allele Symbol</td>
                                        <td class="subHeader">Allele Synonyms</td>
                                        <td class="subHeader">Associated Human Disease</td>
                                        <td class="subHeader">Associated phenotypes</td>
                                        <td class="subHeader">Affected Genomic Model</td>
                                    </tr>
                                    <tr>
                                        <td class="cell"><a href="../allele/">Cit<sup>fhJjlo</sup></a></td>
                                        <td class="cell">CitfhjJlo</td>
                                        <td class="cell"><li><a href="">microcephaly</a></li><li><a href="">visual epilepsy</a></li></td>
                                        <td class="cell"><li>binucleate<br>
                                            <li>decreased forebrain size<br>
                                            <li>flat head
                                        </td>
                                        <td class="cell">Model</td>
                                    </tr>
                                </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <tr>
                    <td>
                            <table width="100%" cellpadding="0" cellspacin="0">
                                <tr>
                                    <td class="header"><br><br>Protein Consequence</td>
                                </tr>
                            </table>





                                            <table width="650" border="0">

                                                <tbody><tr>
                                                    <td>



                                                        <table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                            <tbody><tr>
                                                                <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_006249469</td>
                                                            </tr>
                                                            <tr>
                                                                <td class="carpeLabel">Location:</td><td>EXON</td>
                                                            </tr>


                                                            <tr>
                                                                <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                            </tr>

                                                            <tr>
                                                                <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                            </tr>




                                                            <tr><td></td></tr>


                                                            <tr>
                                                                <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="2">
                                                                    <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                        <tbody><tr>
                                                                            <td class="carpeLabel">Prediction</td>
                                                                            <td class="carpeLabel">Basis</td>
                                                                            <td class="carpeLabel">Effect</td>
                                                                            <td class="carpeLabel">Site</td>
                                                                            <td class="carpeLabel">Score1</td>
                                                                            <td class="carpeLabel">Score2</td>
                                                                            <td class="carpeLabel">Diff</td>
                                                                            <td class="carpeLabel">Number Observed</td>
                                                                            <td class="carpeLabel">Structures</td>
                                                                            <td class="carpeLabel">Protein ID</td>
                                                                            <td class="carpeLabel">PDB ID</td>
                                                                            <td class="carpeLabel">Inverted</td>
                                                                        </tr>


                                                                        <tr>
                                                                            <td>benign</td>
                                                                            <td>alignment</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>-1.508</td>
                                                                            <td>-1.886</td>
                                                                            <td>+0.378</td>
                                                                            <td>152</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>XP_006249531</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>-</td>
                                                                        </tr>

                                                                        </tbody></table>
                                                                </td>
                                                            </tr>



                                                            <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br></td></tr>
                                                            <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKG<br>LFSRRKEDPALPTQVPLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAI<br>VRSPEHQPSAMSLLAPPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMC<br>HPKCSTCLPATCGLPAEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYD<br>NEAREAGQRPVEEFELCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALE<br>SVVAGGRVSREKAEADAAWDCTSCERLPVWVEKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLT<br>HIPGIGAVFQIYIIKDLEKLLMIAGEERALCLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICA<br>AMPSKVVILRYNDNLSKFCIRKEIETSEPCSCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSF<br>PVSIVQANSTGQREEYLLCFHEFGVFVDSYGRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARA<br>YLEIPNPRYLGPAISSGAIYLASSYQDKLRVICCKGNLVKESGTEQHRVPSTSRSPNKRGPPTYNEHITKRVASSPAPPE<br>GPSHPREPSTPHRYRDREGRTELRRDKSPGRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVWD<br>QSSV*</pre></td></tr>



                                                            <tr><td>&nbsp;</td></tr>



                                                            </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_008769269</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                        </tr>



                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>benign</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-1.508</td>
                                                                        <td>-1.886</td>
                                                                        <td>+0.378</td>
                                                                        <td>155</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>XP_008767491</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKG<br>LFSRRKEDPALPTQVPLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAI<br>VRSPEHQPSAMSLLAPPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMC<br>HPKCSTCLPATCGLPAEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYD<br>NEAREAGQRPVEEFELCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALE<br>SVVAGGRVSREKAEADAAWDCTSCERLPVWVEKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLT<br>HIPGIGAVFQIYIIKDLEKLLMIAGEERALCLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICA<br>AMPSKVVILRYNDNLSKFCIRKEIETSEPCSCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSF<br>PVSIVQANSTGQREEYLLCFHEFGVFVDSYGRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARA<br>YLEIPNPRYLGPAISSGAIYLASSYQDKLRVICCKGNLVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPP<br>EGPSHPREPSTPHRYRDREGRTELRRDKSPGRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVW<br>DQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_008769270</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                        </tr>





                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>benign</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-1.508</td>
                                                                        <td>-1.886</td>
                                                                        <td>+0.378</td>
                                                                        <td>155</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>XP_008767492</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKG<br>LFSRRKEDPALPTQVPLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAI<br>VRSPEHQPSAMSLLAPPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMC<br>HPKCSTCLPATCGLPAEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYD<br>NEAREAGQRPVEEFELCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALE<br>SVVAGGRVSREKAEADAAWDCTSCERLPVWVEKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLT<br>HIPGIGAVFQIYIIKDLEKLLMIAGEERALCLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICA<br>AMPSKVVILRYNDNLSKFCIRKEIETSEPCSCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSF<br>PVSIVQANSTGQREEYLLCFHEFGVFVDSYGRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARA<br>YLEIPNPRYLGPAISSGAIYLASSYQDKLRVICCKGNLVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPP<br>EGPSHPREPSTPHRYRDREGRTELRRDKSPGRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVW<br>DQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_008769271</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                        </tr>





                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>benign</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-1.508</td>
                                                                        <td>-1.886</td>
                                                                        <td>+0.378</td>
                                                                        <td>142</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>XP_008767493</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKYSDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREK<br>ATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQLQYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENM<br>IQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDFGSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRG<br>TYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRFLKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHP<br>FFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSPCQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGL<br>DSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSEVEAVLSQKEVELKASETQRSLLEQDLATYITECSSLK<br>RSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQVEEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEE<br>FKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQELQEKLEKAVKASTEATELLQNIRQAKERAERELEKLHN<br>REDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDIQTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQ<br>KEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKILSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSL<br>FTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEKISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQL<br>TELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAEEEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQL<br>TEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREITEREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDEL<br>LEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARADQRITESRQVVELAVKEHKAEILALQQALKEQKLKAES<br>LSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKLQQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEY<br>QLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKGLFSRRKEDPALPTQVPLQYNELKLALEKEKARCAELE<br>EALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAIVRSPEHQPSAMSLLAPPSSRRKEASTPEEFSRRLKER<br>MHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMCHPKCSTCLPATCGLPAEYATHFTEAFCRDKVSSPGLQ<br>SKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYDNEAREAGQRPVEEFELCLPDGDVSIHGAVGASELANT<br>AKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALESVVAGGRVSREKAEADAAWDCTSCERLPVWVEKLLGN<br>SLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLTHIPGIGAVFQIYIIKDLEKLLMIAGEERALCLVDVKK<br>VKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICAAMPSKVVILRYNDNLSKFCIRKEIETSEPCSCIHFTN<br>YSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSFPVSIVQANSTGQREEYLLCFHEFGVFVDSYGRRSRTD<br>DLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARAYLEIPNPRYLGPAISSGAIYLASSYQDKLRVICCKGN<br>LVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPPEGPSHPREPSTPHRYRDREGRTELRRDKSPGRPLERE<br>KSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVWDQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">NM_001029911</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>245</td>
                                                        </tr>





                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>probably damaging</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>NO</td>
                                                                        <td>-1.236</td>
                                                                        <td>-3.265</td>
                                                                        <td>+2.029</td>
                                                                        <td>104</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>NP_001025082</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKV<br>PLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAIVRSPEHQPSAMSLLA<br>PPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMCHPKCSTCLPATCGLP<br>AEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYDNEAREAGQRPVEEFE<br>LCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALESVVAGGRVSREKAEA<br>DAKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLTHIPGIGAVFQIYIIKDLEKLLMIAGEERAL<br>CLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICAAMPSKVVILRYNDNLSKFCIRKEIETSEPC<br>SCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSFPVSIVQANSTGQREEYLLCFHEFGVFVDSY<br>GRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARAYLEIPNPRYLGPAISSGAIYLASSYQDKLR<br>VICCKGNLVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPPEGPSHPREPSTPHRYRDREGRTELRRDKSP<br>GRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVWDQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_006249472</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                        </tr>





                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>probably damaging</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>NO</td>
                                                                        <td>-1.236</td>
                                                                        <td>-3.265</td>
                                                                        <td>+2.029</td>
                                                                        <td>104</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>XP_006249534</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKV<br>PLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAIVRSPEHQPSAMSLLA<br>PPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMCHPKCSTCLPATCGLP<br>AEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYDNEAREAGQRPVEEFE<br>LCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALESVVAGGRVSREKAEA<br>DAKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLTHIPGIGAVFQIYIIKDLEKLLMIAGEERAL<br>CLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICAAMPSKVVILRYNDNLSKFCIRKEIETSEPC<br>SCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSFPVSIVQANSTGQREEYLLCFHEFGVFVDSY<br>GRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARAYLEIPNPRYLGPAISSGAIYLASSYQDKLR<br>VICCKGNLVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPPEGPSHPREPSTPHRYRDREGRTELRRDKSP<br>GRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVWDQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_006249470</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                        </tr>





                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>benign</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-1.508</td>
                                                                        <td>-1.886</td>
                                                                        <td>+0.378</td>
                                                                        <td>145</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>XP_006249532</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKV<br>PLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAIVRSPEHQPSAMSLLA<br>PPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMCHPKCSTCLPATCGLP<br>AEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYDNEAREAGQRPVEEFE<br>LCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALESVVAGGRVSREKAEA<br>DAAWDCTSCERLPVWVEKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLTHIPGIGAVFQIYIIK<br>DLEKLLMIAGEERALCLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICAAMPSKVVILRYNDNL<br>SKFCIRKEIETSEPCSCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSFPVSIVQANSTGQREE<br>YLLCFHEFGVFVDSYGRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARAYLEIPNPRYLGPAIS<br>SGAIYLASSYQDKLRVICCKGNLVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPPEGPSHPREPSTPHRY<br>RDREGRTELRRDKSPGRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVWDQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_006249471</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>EXON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> P to  L (nonsynonymous)</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Position</td><td>222</td>
                                                        </tr>





                                                        <tr><td></td></tr>


                                                        <tr>
                                                            <td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;">Polyphen Predictions</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2">
                                                                <table border="1" cellspacing="0" cellpadding="4" style="background-color:white; font-size:12px;" width="640">
                                                                    <tbody><tr>
                                                                        <td class="carpeLabel">Prediction</td>
                                                                        <td class="carpeLabel">Basis</td>
                                                                        <td class="carpeLabel">Effect</td>
                                                                        <td class="carpeLabel">Site</td>
                                                                        <td class="carpeLabel">Score1</td>
                                                                        <td class="carpeLabel">Score2</td>
                                                                        <td class="carpeLabel">Diff</td>
                                                                        <td class="carpeLabel">Number Observed</td>
                                                                        <td class="carpeLabel">Structures</td>
                                                                        <td class="carpeLabel">Protein ID</td>
                                                                        <td class="carpeLabel">PDB ID</td>
                                                                        <td class="carpeLabel">Inverted</td>
                                                                    </tr>


                                                                    <tr>
                                                                        <td>probably damaging</td>
                                                                        <td>alignment</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-1.236</td>
                                                                        <td>-3.265</td>
                                                                        <td>+2.029</td>
                                                                        <td>111</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>XP_006249533</td>
                                                                        <td>&nbsp;</td>
                                                                        <td>-</td>
                                                                    </tr>

                                                                    </tbody></table>
                                                            </td>
                                                        </tr>



                                                        <tr><td colspan="2" style="color:#053894; font-size:16px;padding-left:5px;font-weight:700;padding-top:5px;"><br>Amino Acid Sequence<br><span style="font-size:12px;">&nbsp;</span></td></tr>
                                                        <tr><td colspan="2" style="border:5px solid #D8D8DB;padding:5px; background-color:white; font-size:12px;"><pre>MLKFKYGVRNPSEASAPEPIASRASRLNLFFQGKPPLMTQQQMSALSREGVLDALFVLLEECSQPALMKIKHVSSFVRKY<br>SDTIAELRELQPSVRDFEVRSLVGCGHFAEVQVVREKATGDVYAMKIMKKAALRAQEQVSFFEEERNILSQSTSPWIPQL<br>QYAFQDKNNLYLVMEYQPGGDLLSLLNRYEDQLDENMIQFYLAELILAVHSVHQMGYVHRDIK<span style="color:red;font-weight:700;font-size:16px;">L</span>ENILIDRTGHIKLVDF<br>GSAAKMNSNKVDAKLPIGTPDYMAPEVLTVMNEDRRGTYGLDCDWWSVGVVAYEMLYGKTPFTEGTSARTFNNIMNFQRF<br>LKFPDDPKVSSELLDLIQSLLCVQKERLKFEGLCCHPFFARTDWNNIRNSPPPFVPTLKSDDDTSNFDEPEKNSWVSSSP<br>CQLSPSGFSGEELPFVGFSYSKALGYLGRSESVVSGLDSPAKISSMEKKLLIKSKELQDSQDKCHKMEQEMARLHRRVSE<br>VEAVLSQKEVELKASETQRSLLEQDLATYITECSSLKRSLEQARMEVSQEDDKALQLLHDIREQSRKLQEIKEQEYQAQV<br>EEMRLMMNQLEEDLVSARRRSDLYESELRESRLAAEEFKRKANECQHKLMKAKDLGKPEVGECSRLEKINAEQQLKIQEL<br>QEKLEKAVKASTEATELLQNIRQAKERAERELEKLHNREDSSEGIKKKLVEAEERRHSLENKVKRLETMERRENRLKDDI<br>QTKSEQIQQMADKILELEEKHREAQVSAQHLEVHLKQKEQHYEEKIKVLDNQIKKDLADKESLETMMQRHEEEAHEKGKI<br>LSEQKAMINAMDSKIRSLEQRIVELSEANKLAANSSLFTQRNMKAQEEMISELRQQKFYLETQAGKLEAQNRKLEEQLEK<br>ISHQDHSDKNRLLELETRLREVSLEHEEQKLELKRQLTELQLSLQERESQLTALQAARAALESQLRQAKTELEETTAEAE<br>EEIQALTAHRDEIQRKFDALRNSCTVITDLEEQLNQLTEDNAELNNQNFYLSKQLDEASGANDEIVQLRSEVDHLRREIT<br>EREMQLTSQKQTMEALKTTCTMLEEQVMDLEALNDELLEKERQWEAWRSVLGDEKSQFECRVRELQRMLDTEKQSRARAD<br>QRITESRQVVELAVKEHKAEILALQQALKEQKLKAESLSDKLNDLEKKHAMLEMNARSLQQKLETERELKQRLLEEQAKL<br>QQQMDLQKNHIFRLTQGLQEALDRADLLKTERSDLEYQLENIQVLYSHEKVKMEGTISQQTKLIDFLQAKMDQPAKKKKG<br>LFSRRKEDPALPTQVPLQYNELKLALEKEKARCAELEEALQKTRIELRSAREEAAHRKATDHPHPSTPATARQQIAMSAI<br>VRSPEHQPSAMSLLAPPSSRRKEASTPEEFSRRLKERMHHNIPHRFNVGLNMRATKCAVCLDTVHFGRQASKCLECQVMC<br>HPKCSTCLPATCGLPAEYATHFTEAFCRDKVSSPGLQSKEPSSSLHLEGWMKVPRNNKRGQQGWDRKYIVLEGSKVLIYD<br>NEAREAGQRPVEEFELCLPDGDVSIHGAVGASELANTAKADVPYILKMESHPHTTCWPGRTLYLLAPSFPDKQRWVTALE<br>SVVAGGRVSREKAEADAKLLGNSLLKLEGDDRLDMNCTLPFSDQVVLVGTEEGLYALNVLKNSLTHIPGIGAVFQIYIIK<br>DLEKLLMIAGEERALCLVDVKKVKQSLAQSHLPAQPDVSPNIFEAVKGCHLFAAGKIENSLCICAAMPSKVVILRYNDNL<br>SKFCIRKEIETSEPCSCIHFTNYSILIGTNKFYEIDMKQYTLEEFLDKNDHSLAPAVFASSTNSFPVSIVQANSTGQREE<br>YLLCFHEFGVFVDSYGRRSRTDDLKWSRLPLAFAYREPYLFVTHFNSLEVIEIQARSSLGTPARAYLEIPNPRYLGPAIS<br>SGAIYLASSYQDKLRVICCKGNLVKESGTEQHRVPSTSRSSPNKRGPPTYNEHITKRVASSPAPPEGPSHPREPSTPHRY<br>RDREGRTELRRDKSPGRPLEREKSPGRMLSTRRERSPGRLFEDSSRGRLPAGAVRTPLSQVNKVWDQSSV*</pre></td></tr>



                                                        <tr><td>&nbsp;</td></tr>



                                                        </tbody></table><table border="0" width="100%" style="border:  5px solid #D8D8DB; background-color:white; color:#053867;font-size:12px;">
                                                        <tbody><tr>
                                                            <td class="carpeLabel" width="200">Accession:</td><td width="70%">XM_006249477</td>
                                                        </tr>
                                                        <tr>
                                                            <td class="carpeLabel">Location:</td><td>INTRON</td>
                                                        </tr>


                                                        <tr>
                                                            <td class="carpeLabel">Amino Acid Prediction:</td><td> &nbsp;</td>
                                                        </tr>





                                                        <tr><td></td></tr>





                                                        <tr><td>&nbsp;</td></tr>




                                                        </tbody></table>
                                                    </td>
                                                </tr>
                                                </tbody></table>


























                    </td>
                </tr>

            </table>




        </td>
    </tr>
</table>