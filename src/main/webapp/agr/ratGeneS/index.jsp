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
  String vars = "12,46334855,46334855,C,T,rs197758291,point mutation,Rat/Rnor_6.0,\n" +
"12,46334878,46334878,C,T,rs198886146,point mutation,Rat/Rnor_6.0,\n" +
"12,46335097,46335097,G,A,rs106165986,point mutation,Rat/Rnor_6.0,\n" +
"12,46335228,46335228,A,C,rs106840596,point mutation,Rat/Rnor_6.0,\n" +
"12,46493042,46493042,C,-,,deletion,Rat/Rnor,frameshift,Probably Damaging,\n" +
"12,46335425,46335425,T,C,rs107382904,point mutation,Rat/Rnor_6.0,\n" +
"12,46335967,46335967,A,G,rs197716245,point mutation,Rat/Rnor_6.0,\n" +
"12,46336416,46336416,T,C,rs199026308,point mutation,Rat/Rnor_6.0,\n" +
"12,46336794,46336794,G,C,rs197171374,point mutation,Rat/Rnor_6.0,\n" +
"12,46336795,46336795,A,C,rs197992156,point mutation,Rat/Rnor_6.0,\n" +
"12,46336877,46336877,C,T,rs198718315,point mutation,Rat/Rnor_6.0,\n" +
"12,46337443,46337443,C,T,rs197111748,point mutation,Rat/Rnor_6.0,\n" +
"12,46338133,46338133,G,A,rs105317699,point mutation,Rat/Rnor_6.0,\n" +
"12,46338391,46338391,G,A,rs106911794,point mutation,Rat/Rnor_6.0,\n" +
"12,46338579,46338579,G,A,rs199178661,point mutation,Rat/Rnor_6.0,\n" +
"12,46339105,46339105,G,T,rs106970881,point mutation,Rat/Rnor_6.0,\n" +
"12,46339233,46339233,A,C,rs105602317,point mutation,Rat/Rnor_6.0,\n" +
"12,46340125,46340125,C,T,rs106702647,point mutation,Rat/Rnor_6.0,\n" +
"12,46340880,46340880,T,C,rs105180818,point mutation,Rat/Rnor_6.0,\n" +
"12,46341173,46341173,T,G,rs106604683,point mutation,Rat/Rnor_6.0,\n" +
"12,46341181,46341181,T,G,rs105983104,point mutation,Rat/Rnor_6.0,\n" +
"12,46341443,46341443,A,C,rs106275589,point mutation,Rat/Rnor_6.0,\n" +
"12,46341446,46341446,A,G,rs106371410,point mutation,Rat/Rnor_6.0,\n" +
"12,46341763,46341763,T,G,rs106820333,point mutation,Rat/Rnor_6.0,\n" +
"12,46342114,46342114,A,G,rs106945198,point mutation,Rat/Rnor_6.0,\n" +
"12,46342177,46342177,A,C,rs105712299,point mutation,Rat/Rnor_6.0,\n" +
"12,46342290,46342290,A,G,rs107295594,point mutation,Rat/Rnor_6.0,\n" +
"12,46342409,46342409,T,C,rs105188029,point mutation,Rat/Rnor_6.0,\n" +
"12,46342449,46342449,A,G,rs197995884,point mutation,Rat/Rnor_6.0,\n" +
"12,46342582,46342582,G,A,rs199021644,point mutation,Rat/Rnor_6.0,\n" +
"12,46342711,46342711,A,C,rs106155636,point mutation,Rat/Rnor_6.0,\n" +
"12,46343937,46343937,A,G,rs198069613,point mutation,Rat/Rnor_6.0,\n" +
"12,46344325,46344325,T,C,rs199118622,point mutation,Rat/Rnor_6.0,\n" +
"12,46344440,46344440,A,G,rs197498229,point mutation,Rat/Rnor_6.0,\n" +
"12,46344693,46344693,A,C,rs198117644,point mutation,Rat/Rnor_6.0,\n" +
"12,46345433,46345433,T,C,rs107148724,point mutation,Rat/Rnor_6.0,\n" +
"12,46345979,46345979,T,C,rs105984012,point mutation,Rat/Rnor_6.0,\n" +
"12,46346319,46346319,T,C,rs105866336,point mutation,Rat/Rnor_6.0,\n" +
"12,46346566,46346566,G,A,rs107197441,point mutation,Rat/Rnor_6.0,\n" +
"12,46347188,46347188,T,C,rs198211707,point mutation,Rat/Rnor_6.0,\n" +
"12,46347251,46347251,T,C,rs198740401,point mutation,Rat/Rnor_6.0,\n" +
"12,46347519,46347519,A,G,rs197768810,point mutation,Rat/Rnor_6.0,\n" +
"12,46347684,46347684,C,G,rs105082531,point mutation,Rat/Rnor_6.0,\n" +
"12,46347724,46347724,G,A,rs107314855,point mutation,Rat/Rnor_6.0,\n" +
"12,46347965,46347965,C,T,rs106817542,point mutation,Rat/Rnor_6.0,\n" +
"12,46348077,46348077,G,A,rs106447923,point mutation,Rat/Rnor_6.0,\n" +
"12,46348132,46348132,T,C,rs107588080,point mutation,Rat/Rnor_6.0,\n" +
"12,46348848,46348848,T,A,rs107281935,point mutation,Rat/Rnor_6.0,\n" +
"12,46349022,46349022,T,G,rs106769500,point mutation,Rat/Rnor_6.0,\n" +
"12,46349213,46349213,T,G,rs106855421,point mutation,Rat/Rnor_6.0,\n" +
"12,46349694,46349694,A,G,rs106407722,point mutation,Rat/Rnor_6.0,\n" +
"12,46350391,46350391,A,G,rs197239836,point mutation,Rat/Rnor_6.0,\n" +
"12,46350412,46350412,C,T,rs198058980,point mutation,Rat/Rnor_6.0,\n" +
"12,46353222,46353222,C,T,rs198529459,point mutation,Rat/Rnor_6.0,\n" +
"12,46354141,46354141,A,G,rs198664579,point mutation,Rat/Rnor_6.0,\n" +
"12,46354158,46354158,G,A,rs197347833,point mutation,Rat/Rnor_6.0,\n" +
"12,46355864,46355864,T,C,rs198247166,point mutation,Rat/Rnor_6.0,\n" +
"12,46357508,46357508,G,C,rs106999455,point mutation,Rat/Rnor_6.0,\n" +
"12,46360297,46360297,A,G,rs197552564,point mutation,Rat/Rnor_6.0,\n" +
"12,46360736,46360736,C,T,rs106889425,point mutation,Rat/Rnor_6.0,\n" +
"12,46360895,46360895,T,C,rs198775009,point mutation,Rat/Rnor_6.0,\n" +
"12,46361436,46361436,T,C,rs198806780,point mutation,Rat/Rnor_6.0,\n" +
"12,46362711,46362711,T,C,rs197861643,point mutation,Rat/Rnor_6.0,\n" +
"12,46365368,46365368,G,A,rs106024358,point mutation,Rat/Rnor_6.0,\n" +
"12,46366387,46366387,T,C,rs197261773,point mutation,Rat/Rnor_6.0,\n" +
"12,46366765,46366765,A,G,rs198491181,point mutation,Rat/Rnor_6.0,\n" +
"12,46367354,46367354,C,T,rs105423859,point mutation,Rat/Rnor_6.0,\n" +
"12,46367432,46367432,T,G,rs107557073,point mutation,Rat/Rnor_6.0,\n" +
"12,46367815,46367815,C,T,rs105121210,point mutation,Rat/Rnor_6.0,\n" +
"12,46368548,46368548,C,T,rs105968901,point mutation,Rat/Rnor_6.0,\n" +
"12,46368653,46368653,C,T,rs105291434,point mutation,Rat/Rnor_6.0,\n" +
"12,46369135,46369135,T,C,rs198582500,point mutation,Rat/Rnor_6.0,\n" +
"12,46369492,46369492,G,A,rs106909882,point mutation,Rat/Rnor_6.0,\n" +
"12,46369784,46369784,G,A,rs105615077,point mutation,Rat/Rnor_6.0,\n" +
"12,46369805,46369805,T,C,rs105380829,point mutation,Rat/Rnor_6.0,\n" +
"12,46370700,46370700,T,G,rs198107199,point mutation,Rat/Rnor_6.0,\n" +
"12,46371834,46371834,G,A,rs106365295,point mutation,Rat/Rnor_6.0,\n" +
"12,46372673,46372673,G,A,rs197755707,point mutation,Rat/Rnor_6.0,\n" +
"12,46373118,46373118,A,G,rs105877068,point mutation,Rat/Rnor_6.0,\n" +
"12,46373131,46373131,G,A,rs106498353,point mutation,Rat/Rnor_6.0,\n" +
"12,46373226,46373226,G,A,rs107478367,point mutation,Rat/Rnor_6.0,\n" +
"12,46373230,46373230,T,C,rs105297825,point mutation,Rat/Rnor_6.0,\n" +
"12,46373257,46373257,C,T,rs106868642,point mutation,Rat/Rnor_6.0,\n" +
"12,46373523,46373523,G,A,rs105191406,point mutation,Rat/Rnor_6.0,\n" +
"12,46373986,46373986,T,C,rs107211477,point mutation,Rat/Rnor_6.0,\n" +
"12,46373987,46373987,G,A,rs106162552,point mutation,Rat/Rnor_6.0,\n" +
"12,46378502,46378502,G,C,rs107182117,point mutation,Rat/Rnor_6.0,\n" +
"12,46378737,46378737,C,T,rs106362975,point mutation,Rat/Rnor_6.0,\n" +
"12,46380020,46380020,G,A,rs106712462,point mutation,Rat/Rnor_6.0,\n" +
"12,46388388,46388388,A,G,rs198390441,point mutation,Rat/Rnor_6.0,\n" +
"12,46388606,46388606,G,A,rs197985918,point mutation,Rat/Rnor_6.0,\n" +
"12,46388955,46388955,A,G,rs198332309,point mutation,Rat/Rnor_6.0,\n" +
"12,46390422,46390422,G,A,rs106712584,point mutation,Rat/Rnor_6.0,\n" +
"12,46391391,46391391,G,A,rs106760880,point mutation,Rat/Rnor_6.0,\n" +
"12,46393881,46393881,T,G,rs197885397,point mutation,Rat/Rnor_6.0,\n" +
"12,46394126,46394126,C,T,rs199249163,point mutation,Rat/Rnor_6.0,\n" +
"12,46395389,46395389,C,G,rs105719610,point mutation,Rat/Rnor_6.0,\n" +
"12,46395419,46395419,C,G,rs105694720,point mutation,Rat/Rnor_6.0,\n" +
"12,46395423,46395423,C,G,rs106263400,point mutation,Rat/Rnor_6.0,\n" +
"12,46395503,46395503,G,C,rs198317371,point mutation,Rat/Rnor_6.0,\n" +
"12,46399641,46399641,T,C,rs107363459,point mutation,Rat/Rnor_6.0,\n" +
"12,46400017,46400017,T,C,rs105767663,point mutation,Rat/Rnor_6.0,\n" +
"12,46401797,46401797,T,C,rs105365986,point mutation,Rat/Rnor_6.0,\n" +
"12,46402906,46402906,C,T,rs198687282,point mutation,Rat/Rnor_6.0,\n" +
"12,46404468,46404468,A,G,rs105618233,point mutation,Rat/Rnor_6.0,\n" +
"12,46404678,46404678,G,A,rs197553258,point mutation,Rat/Rnor_6.0,\n" +
"12,46405245,46405245,T,C,rs107531569,point mutation,Rat/Rnor_6.0,\n" +
"12,46405264,46405264,A,G,rs198097775,point mutation,Rat/Rnor_6.0,\n" +
"12,46406364,46406364,C,A,rs105028117,point mutation,Rat/Rnor_6.0,\n" +
"12,46406520,46406520,A,G,rs199408092,point mutation,Rat/Rnor_6.0,\n" +
"12,46407524,46407524,G,A,rs197593165,point mutation,Rat/Rnor_6.0,\n" +
"12,46408850,46408850,A,G,rs199119176,point mutation,Rat/Rnor_6.0,\n" +
"12,46409728,46409728,G,A,rs106705329,point mutation,Rat/Rnor_6.0,\n" +
"12,46410849,46410849,G,A,rs198840092,point mutation,Rat/Rnor_6.0,\n" +
"12,46411052,46411052,A,G,rs197581414,point mutation,Rat/Rnor_6.0,\n" +
"12,46411085,46411085,G,A,rs106930298,point mutation,Rat/Rnor_6.0,\n" +
"12,46413239,46413239,C,G,rs198465496,point mutation,Rat/Rnor_6.0,\n" +
"12,46414736,46414736,T,A,rs197008343,point mutation,Rat/Rnor_6.0,\n" +
"12,46414846,46414846,A,G,rs107170335,point mutation,Rat/Rnor_6.0,\n" +
"12,46415937,46415937,G,A,rs106848905,point mutation,Rat/Rnor_6.0,\n" +
"12,46415943,46415943,C,G,rs105210372,point mutation,Rat/Rnor_6.0,\n" +
"12,46416410,46416410,T,C,rs107267273,point mutation,Rat/Rnor_6.0,\n" +
"12,46416504,46416504,G,A,rs65528624,point mutation,Rat/Rnor_6.0,\n" +
"12,46416680,46416680,A,G,rs63903752,point mutation,Rat/Rnor_6.0,\n" +
"12,46419028,46419028,T,C,rs198115727,point mutation,Rat/Rnor_6.0,\n" +
"12,46419375,46419375,A,G,rs106848872,point mutation,Rat/Rnor_6.0,\n" +
"12,46419585,46419585,C,T,rs106655881,point mutation,Rat/Rnor_6.0,\n" +
"12,46419830,46419830,T,C,rs107177765,point mutation,Rat/Rnor_6.0,\n" +
"12,46421302,46421302,C,T,rs198851622,point mutation,Rat/Rnor_6.0,\n" +
"12,46423780,46423780,G,A,rs198856031,point mutation,Rat/Rnor_6.0,\n" +
"12,46424533,46424533,T,A,rs105361280,point mutation,Rat/Rnor_6.0,\n" +
"12,46424556,46424556,T,C,rs197767119,point mutation,Rat/Rnor_6.0,\n" +
"12,46425279,46425279,A,G,rs198398175,point mutation,Rat/Rnor_6.0,\n" +
"12,46425438,46425438,G,A,rs198926705,point mutation,Rat/Rnor_6.0,\n" +
"12,46426064,46426064,T,C,rs106194743,point mutation,Rat/Rnor_6.0,\n" +
"12,46426883,46426883,G,A,rs107118107,point mutation,Rat/Rnor_6.0,\n" +
"12,46427338,46427338,G,A,rs107353432,point mutation,Rat/Rnor_6.0,\n" +
"12,46427408,46427408,T,G,rs105890014,point mutation,Rat/Rnor_6.0,\n" +
"12,46427939,46427939,T,C,rs197017607,point mutation,Rat/Rnor_6.0,\n" +
"12,46427947,46427947,C,T,rs198342209,point mutation,Rat/Rnor_6.0,\n" +
"12,46428230,46428230,T,C,rs197236476,point mutation,Rat/Rnor_6.0,\n" +
"12,46428714,46428714,G,A,rs105899135,point mutation,Rat/Rnor_6.0,\n" +
"12,46430321,46430321,G,A,rs197930424,point mutation,Rat/Rnor_6.0,\n" +
"12,46431063,46431063,A,G,rs199137709,point mutation,Rat/Rnor_6.0,\n" +
"12,46432057,46432057,C,T,rs197448547,point mutation,Rat/Rnor_6.0,\n" +
"12,46432256,46432256,G,A,rs198121843,point mutation,Rat/Rnor_6.0,\n" +
"12,46432258,46432258,C,A,rs198712326,point mutation,Rat/Rnor_6.0,\n" +
"12,46434359,46434359,A,G,rs107365428,point mutation,Rat/Rnor_6.0,\n" +
"12,46434436,46434436,A,G,rs107425656,point mutation,Rat/Rnor_6.0,\n" +
"12,46434956,46434956,A,G,rs105586698,point mutation,Rat/Rnor_6.0,\n" +
"12,46435344,46435344,T,C,rs106232647,point mutation,Rat/Rnor_6.0,\n" +
"12,46435541,46435541,G,A,rs106285953,point mutation,Rat/Rnor_6.0,\n" +
"12,46436147,46436147,C,A,rs107591643,point mutation,Rat/Rnor_6.0,\n" +
"12,46437123,46437123,T,A,rs105486483,point mutation,Rat/Rnor_6.0,\n" +
"12,46437363,46437363,T,C,rs107153681,point mutation,Rat/Rnor_6.0,\n" +
"12,46437480,46437480,C,T,rs106831865,point mutation,Rat/Rnor_6.0,\n" +
"12,46438865,46438865,A,G,rs106389206,point mutation,Rat/Rnor_6.0,\n" +
"12,46439167,46439167,G,A,rs197254110,point mutation,Rat/Rnor_6.0,\n" +
"12,46439957,46439957,A,G,rs105328698,point mutation,Rat/Rnor_6.0,\n" +
"12,46440084,46440084,G,A,rs105784138,point mutation,Rat/Rnor_6.0,\n" +
"12,46440127,46440127,G,A,rs105951841,point mutation,Rat/Rnor_6.0,\n" +
"12,46440383,46440383,A,C,rs199085615,point mutation,Rat/Rnor_6.0,\n" +
"12,46440384,46440384,C,A,rs197124384,point mutation,Rat/Rnor_6.0,\n" +
"12,46440435,46440435,T,G,rs197984980,point mutation,Rat/Rnor_6.0,\n" +
"12,46440444,46440444,A,C,rs198674218,point mutation,Rat/Rnor_6.0,\n" +
"12,46441727,46441727,C,A,rs105195090,point mutation,Rat/Rnor_6.0,\n" +
"12,46441789,46441789,G,A,rs197057997,point mutation,Rat/Rnor_6.0,\n" +
"12,46441943,46441943,T,A,rs107360476,point mutation,Rat/Rnor_6.0,\n" +
"12,46445354,46445354,A,G,rs198628456,point mutation,Rat/Rnor_6.0,\n" +
"12,46447182,46447182,G,A,rs107034519,point mutation,Rat/Rnor_6.0,\n" +
"12,46449063,46449063,T,C,rs197528346,point mutation,Rat/Rnor_6.0,\n" +
"12,46449271,46449271,A,T,rs198215899,point mutation,Rat/Rnor_6.0,\n" +
"12,46449282,46449282,C,A,rs199133227,point mutation,Rat/Rnor_6.0,\n" +
"12,46449490,46449490,A,G,rs106471012,point mutation,Rat/Rnor_6.0,\n" +
"12,46449516,46449516,C,A,rs107139661,point mutation,Rat/Rnor_6.0,\n" +
"12,46450408,46450408,A,G,rs105630870,point mutation,Rat/Rnor_6.0,\n" +
"12,46451335,46451335,G,T,rs106604481,point mutation,Rat/Rnor_6.0,\n" +
"12,46452529,46452529,A,G,rs198838903,point mutation,Rat/Rnor_6.0,\n" +
"12,46453675,46453675,A,G,rs199296721,point mutation,Rat/Rnor_6.0,\n" +
"12,46453807,46453807,T,G,rs199027060,point mutation,Rat/Rnor_6.0,\n" +
"12,46455350,46455350,C,T,rs106075991,point mutation,Rat/Rnor_6.0,\n" +
"12,46455881,46455881,A,G,rs107387128,point mutation,Rat/Rnor_6.0,\n" +
"12,46455887,46455887,G,A,rs106181059,point mutation,Rat/Rnor_6.0,\n" +
"12,46455892,46455892,G,A,rs197773517,point mutation,Rat/Rnor_6.0,\n" +
"12,46458013,46458013,G,T,rs107497771,point mutation,Rat/Rnor_6.0,\n" +
"12,46459186,46459186,G,C,rs199020676,point mutation,Rat/Rnor_6.0,\n" +
"12,46459268,46459268,A,G,rs105592049,point mutation,Rat/Rnor_6.0,\n" +
"12,46459392,46459392,C,A,rs197979115,point mutation,Rat/Rnor_6.0,\n" +
"12,46460027,46460027,A,G,rs106556960,point mutation,Rat/Rnor_6.0,\n" +
"12,46460086,46460086,A,C,rs198327607,point mutation,Rat/Rnor_6.0,\n" +
"12,46460348,46460348,C,T,rs105825105,point mutation,Rat/Rnor_6.0,\n" +
"12,46463089,46463089,A,G,rs197090040,point mutation,Rat/Rnor_6.0,\n" +
"12,46463511,46463511,G,A,,point mutation,Rat/Rnor_6.0,nonsynonymous,probably damaging\n" +
"12,46464176,46464176,T,A,rs63854586,point mutation,Rat/Rnor_6.0,\n" +
"12,46464381,46464381,T,C,rs198669689,point mutation,Rat/Rnor_6.0,\n" +
"12,46464650,46464650,C,T,rs198020391,point mutation,Rat/Rnor_6.0,\n" +
"12,46464738,46464738,C,T,rs199194210,point mutation,Rat/Rnor_6.0,\n" +
"12,46465246,46465246,G,A,rs197599711,point mutation,Rat/Rnor_6.0,\n" +
"12,46465902,46465902,G,A,rs65299179,point mutation,Rat/Rnor_6.0,\n" +
"12,46465971,46465971,G,A,rs65101615,point mutation,Rat/Rnor_6.0,\n" +
"12,46466932,46466932,A,G,rs104987188,point mutation,Rat/Rnor_6.0,\n" +
"12,46467754,46467754,A,T,rs198664004,point mutation,Rat/Rnor_6.0,\n" +
"12,46468709,46468709,T,C,rs198932450,point mutation,Rat/Rnor_6.0,\n" +
"12,46468758,46468758,G,A,rs197730702,point mutation,Rat/Rnor_6.0,\n" +
"12,46469110,46469110,G,A,rs198492975,point mutation,Rat/Rnor_6.0,\n" +
"12,46469279,46469279,A,G,rs197579337,point mutation,Rat/Rnor_6.0,\n" +
"12,46469306,46469306,T,C,rs198464480,point mutation,Rat/Rnor_6.0,\n" +
"12,46469397,46469397,T,C,rs196997910,point mutation,Rat/Rnor_6.0,\n" +
"12,46469983,46469983,C,T,rs105069931,point mutation,Rat/Rnor_6.0,\n" +
"12,46470410,46470410,A,G,rs199015281,point mutation,Rat/Rnor_6.0,\n" +
"12,46470737,46470737,C,T,rs197241615,point mutation,Rat/Rnor_6.0,\n" +
"12,46470755,46470755,G,A,rs198043098,point mutation,Rat/Rnor_6.0,\n" +
"12,46471029,46471029,T,C,rs198113329,point mutation,Rat/Rnor_6.0,\n" +
"12,46471260,46471260,A,G,rs105154058,point mutation,Rat/Rnor_6.0,\n" +
"12,46471429,46471429,A,G,rs105564636,point mutation,Rat/Rnor_6.0,\n" +
"12,46471638,46471638,G,A,rs106448184,point mutation,Rat/Rnor_6.0,\n" +
"12,46471794,46471794,A,T,rs197274291,point mutation,Rat/Rnor_6.0,\n" +
"12,46471821,46471821,C,T,rs104960880,point mutation,Rat/Rnor_6.0,\n" +
"12,46471885,46471885,G,A,rs104945056,point mutation,Rat/Rnor_6.0,\n" +
"12,46472631,46472631,A,G,rs105552602,point mutation,Rat/Rnor_6.0,\n" +
"12,46472774,46472774,G,A,rs105221739,point mutation,Rat/Rnor_6.0,\n" +
"12,46473268,46473268,C,T,rs198924752,point mutation,Rat/Rnor_6.0,\n" +
"12,46473781,46473781,C,T,rs197723166,point mutation,Rat/Rnor_6.0,\n" +
"12,46474001,46474001,G,A,rs197116691,point mutation,Rat/Rnor_6.0,\n" +
"12,46474711,46474711,G,A,rs197522053,point mutation,Rat/Rnor_6.0,\n" +
"12,46475027,46475027,A,G,rs199080224,point mutation,Rat/Rnor_6.0,\n" +
"12,46475053,46475053,A,G,rs107029373,point mutation,Rat/Rnor_6.0,\n" +
"12,46475718,46475718,C,T,rs105317842,point mutation,Rat/Rnor_6.0,\n" +
"12,46475727,46475727,T,C,rs199178778,point mutation,Rat/Rnor_6.0,\n" +
"12,46475939,46475939,G,C,rs107543038,point mutation,Rat/Rnor_6.0,\n" +
"12,46476119,46476119,T,G,rs107564714,point mutation,Rat/Rnor_6.0,\n" +
"12,46476237,46476237,G,A,rs198519631,point mutation,Rat/Rnor_6.0,\n" +
"12,46476433,46476433,C,A,rs197508201,point mutation,Rat/Rnor_6.0,\n" +
"12,46476493,46476493,A,T,rs198705044,point mutation,Rat/Rnor_6.0,\n" +
"12,46476570,46476570,C,T,rs197335433,point mutation,Rat/Rnor_6.0,\n" +
"12,46476755,46476755,C,T,rs198290278,point mutation,Rat/Rnor_6.0,\n" +
"12,46476806,46476806,A,G,rs198843760,point mutation,Rat/Rnor_6.0,\n" +
"12,46476866,46476866,G,A,rs197537304,point mutation,Rat/Rnor_6.0,\n" +
"12,46477000,46477000,G,A,rs198756848,point mutation,Rat/Rnor_6.0,\n" +
"12,46477010,46477010,C,T,rs198798393,point mutation,Rat/Rnor_6.0,\n" +
"12,46477116,46477116,G,A,rs197781158,point mutation,Rat/Rnor_6.0,\n" +
"12,46477315,46477315,T,G,rs106689864,point mutation,Rat/Rnor_6.0,\n" +
"12,46477653,46477653,C,A,rs197333476,point mutation,Rat/Rnor_6.0,\n" +
"12,46477745,46477745,G,C,rs197107193,point mutation,Rat/Rnor_6.0,\n" +
"12,46477880,46477880,G,A,rs197881914,point mutation,Rat/Rnor_6.0,\n" +
"12,46478112,46478112,T,C,rs199247237,point mutation,Rat/Rnor_6.0,\n" +
"12,46478227,46478227,A,C,rs197070078,point mutation,Rat/Rnor_6.0,\n" +
"12,46478265,46478265,G,A,rs198311260,point mutation,Rat/Rnor_6.0,\n" +
"12,46478337,46478337,G,A,rs198625327,point mutation,Rat/Rnor_6.0,\n" +
"12,46478964,46478964,A,G,rs105411604,point mutation,Rat/Rnor_6.0,\n" +
"12,46479126,46479126,C,G,rs105974722,point mutation,Rat/Rnor_6.0,\n" +
"12,46479324,46479324,T,C,rs106614423,point mutation,Rat/Rnor_6.0,\n" +
"12,46479706,46479706,C,T,rs106801112,point mutation,Rat/Rnor_6.0,\n" +
"12,46480033,46480033,C,T,rs105107799,point mutation,Rat/Rnor_6.0,\n" +
"12,46480111,46480111,G,A,rs107537732,point mutation,Rat/Rnor_6.0,\n" +
"12,46480260,46480260,A,G,rs106200908,point mutation,Rat/Rnor_6.0,\n" +
"12,46480546,46480546,A,G,rs106394418,point mutation,Rat/Rnor_6.0,\n" +
"12,46480616,46480616,T,C,rs107222349,point mutation,Rat/Rnor_6.0,\n" +
"12,46481027,46481027,G,A,rs198792933,point mutation,Rat/Rnor_6.0,\n" +
"12,46481193,46481193,C,T,rs197858345,point mutation,Rat/Rnor_6.0,\n" +
"12,46481375,46481375,A,G,rs106463924,point mutation,Rat/Rnor_6.0,\n" +
"12,46481608,46481608,A,C,rs197242498,point mutation,Rat/Rnor_6.0,\n" +
"12,46481678,46481678,A,G,rs198326081,point mutation,Rat/Rnor_6.0,\n" +
"12,46481923,46481923,G,A,rs197079356,point mutation,Rat/Rnor_6.0,\n" +
"12,46481959,46481959,T,C,rs197911599,point mutation,Rat/Rnor_6.0,\n" +
"12,46482030,46482030,A,G,rs198664440,point mutation,Rat/Rnor_6.0,\n" +
"12,46482036,46482036,A,G,rs197329503,point mutation,Rat/Rnor_6.0,\n" +
"12,46482060,46482060,G,A,rs198511059,point mutation,Rat/Rnor_6.0,\n" +
"12,46482071,46482071,A,G,rs198622209,point mutation,Rat/Rnor_6.0,\n" +
"12,46482116,46482116,G,A,rs197293199,point mutation,Rat/Rnor_6.0,\n" +
"12,46482138,46482138,A,G,rs105701952,point mutation,Rat/Rnor_6.0,\n" +
"12,46482216,46482216,A,G,rs106114015,point mutation,Rat/Rnor_6.0,\n" +
"12,46482308,46482308,C,T,rs198572601,point mutation,Rat/Rnor_6.0,\n" +
"12,46482309,46482309,A,G,rs107558743,point mutation,Rat/Rnor_6.0,\n" +
"12,46482412,46482412,G,A,rs105449914,point mutation,Rat/Rnor_6.0,\n" +
"12,46482507,46482507,G,T,rs106038013,point mutation,Rat/Rnor_6.0,\n" +
"12,46482549,46482549,C,A,rs107362673,point mutation,Rat/Rnor_6.0,\n" +
"12,46482678,46482678,T,C,rs106360059,point mutation,Rat/Rnor_6.0,\n" +
"12,46482873,46482873,A,G,rs107364557,point mutation,Rat/Rnor_6.0,\n" +
"12,46483022,46483022,T,A,rs107379541,point mutation,Rat/Rnor_6.0,\n" +
"12,46483148,46483148,C,T,rs198063805,point mutation,Rat/Rnor_6.0,\n" +
"12,46483282,46483282,G,A,rs198422676,point mutation,Rat/Rnor_6.0,\n" +
"12,46483424,46483424,T,C,rs197994681,point mutation,Rat/Rnor_6.0,\n" +
"12,46483456,46483456,C,T,rs199136270,point mutation,Rat/Rnor_6.0,\n" +
"12,46483525,46483525,A,C,rs197553502,point mutation,Rat/Rnor_6.0,\n" +
"12,46484308,46484308,A,G,rs198101143,point mutation,Rat/Rnor_6.0,\n" +
"12,46484374,46484374,C,T,rs199229729,point mutation,Rat/Rnor_6.0,\n" +
"12,46484434,46484434,G,A,rs197428752,point mutation,Rat/Rnor_6.0,\n" +
"12,46484451,46484451,T,G,rs198851205,point mutation,Rat/Rnor_6.0,\n" +
"12,46484476,46484476,G,A,rs198611744,point mutation,Rat/Rnor_6.0,\n" +
"12,46484493,46484493,T,G,rs197277076,point mutation,Rat/Rnor_6.0,\n" +
"12,46485049,46485049,A,G,rs107293504,point mutation,Rat/Rnor_6.0,\n" +
"12,46485217,46485217,G,A,rs106408575,point mutation,Rat/Rnor_6.0,\n" +
"12,46485453,46485453,G,A,rs104920824,point mutation,Rat/Rnor_6.0,\n" +
"12,46485472,46485472,G,T,rs106490934,point mutation,Rat/Rnor_6.0,\n" +
"12,46485503,46485503,G,A,rs106386757,point mutation,Rat/Rnor_6.0,\n" +
"12,46486688,46486688,T,C,rs105027311,point mutation,Rat/Rnor_6.0,\n" +
"12,46487024,46487024,T,C,rs197679159,point mutation,Rat/Rnor_6.0,\n" +
"12,46487269,46487269,A,C,rs198988346,point mutation,Rat/Rnor_6.0,\n" +
"12,46487457,46487457,G,A,rs197114582,point mutation,Rat/Rnor_6.0,\n" +
"12,46487614,46487614,A,G,rs197654367,point mutation,Rat/Rnor_6.0,\n" +
"12,46487693,46487693,A,G,rs198457491,point mutation,Rat/Rnor_6.0,\n" +
"12,46487751,46487751,A,T,rs105241769,point mutation,Rat/Rnor_6.0,\n" +
"12,46487839,46487839,G,A,rs198335814,point mutation,Rat/Rnor_6.0,\n" +
"12,46487863,46487863,C,T,rs105139294,point mutation,Rat/Rnor_6.0,\n" +
"12,46487869,46487869,G,A,rs105927520,point mutation,Rat/Rnor_6.0,\n" +
"12,46487972,46487972,C,T,rs105235114,point mutation,Rat/Rnor_6.0,\n" +
"12,46488033,46488033,C,A,rs105967865,point mutation,Rat/Rnor_6.0,\n" +
"12,46488114,46488114,A,G,rs105639906,point mutation,Rat/Rnor_6.0,\n" +
"12,46488122,46488122,C,G,rs106399449,point mutation,Rat/Rnor_6.0,\n" +
"12,46488420,46488420,A,G,rs107357086,point mutation,Rat/Rnor_6.0,\n" +
"12,46488840,46488840,C,G,rs198282921,point mutation,Rat/Rnor_6.0,\n" +
"12,46489267,46489267,T,C,rs107559473,point mutation,Rat/Rnor_6.0,\n" +
"12,46490257,46490257,C,G,rs106104053,point mutation,Rat/Rnor_6.0,\n" +
"12,46490293,46490293,C,A,rs105569246,point mutation,Rat/Rnor_6.0,\n" +
"12,46490300,46490300,T,G,rs105614725,point mutation,Rat/Rnor_6.0,\n" +
"12,46490314,46490314,C,T,rs107217052,point mutation,Rat/Rnor_6.0,\n" +
"12,46490495,46490495,T,C,rs105153258,point mutation,Rat/Rnor_6.0,\n" +
"12,46490519,46490519,C,T,rs197331857,point mutation,Rat/Rnor_6.0,\n" +
"12,46490601,46490601,C,T,rs104967383,point mutation,Rat/Rnor_6.0,\n" +
"12,46490730,46490730,A,C,rs105322335,point mutation,Rat/Rnor_6.0,\n" +
"12,46490946,46490946,T,C,rs106965919,point mutation,Rat/Rnor_6.0,\n" +
"12,46490955,46490955,C,A,rs106385518,point mutation,Rat/Rnor_6.0,\n" +
"12,46491238,46491238,A,T,rs106626193,point mutation,Rat/Rnor_6.0,\n" +
"12,46491679,46491679,C,T,rs198672384,point mutation,Rat/Rnor_6.0,\n" +
"12,46492011,46492011,A,C,rs105367034,point mutation,Rat/Rnor_6.0,\n" +
"12,46492189,46492189,G,A,rs105536401,point mutation,Rat/Rnor_6.0,\n" +
"12,46492326,46492326,G,A,rs197275688,point mutation,Rat/Rnor_6.0,\n" +
"12,46492364,46492364,G,T,rs198003643,point mutation,Rat/Rnor_6.0,\n" +
"12,46492393,46492393,G,C,rs198575034,point mutation,Rat/Rnor_6.0,\n" +
"12,46492533,46492533,A,G,rs197427889,point mutation,Rat/Rnor_6.0,\n" +
"12,46492553,46492553,G,A,rs198675114,point mutation,Rat/Rnor_6.0,\n" +
"12,46492559,46492559,C,G,rs198931637,point mutation,Rat/Rnor_6.0,\n" +
"12,46493065,46493065,T,A,rs197419822,point mutation,Rat/Rnor_6.0,\n" +
"12,46493237,46493237,G,A,rs105000227,point mutation,Rat/Rnor_6.0,\n" +
"12,46493475,46493475,T,G,rs105831465,point mutation,Rat/Rnor_6.0,\n" +
"12,46493593,46493593,C,T,rs199326396,point mutation,Rat/Rnor_6.0,\n" +
"12,46493665,46493665,A,G,rs199054910,point mutation,Rat/Rnor_6.0,\n" +
"12,46493669,46493669,C,A,rs199257001,point mutation,Rat/Rnor_6.0,\n" +
"12,46493812,46493812,A,C,rs197768409,point mutation,Rat/Rnor_6.0,\n" +
"12,46493987,46493987,A,G,rs106452346,point mutation,Rat/Rnor_6.0,\n" +
"12,46493042,46493042,C,-,,deletion,Rat/Rnor,frameshift,Probably Damaging";
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
                    <td><img src="head.png"/></td>
                </tr>
                <tr>
                    <td><img src="sequence.png"/></td>
                </tr>
                <tr>
                    <td><img src="go.png"/></td>
                </tr>
                <tr>
                    <td><img src="ortho.png"/></td>
                </tr>
                <tr>
                    <td><img src="pheno.png"/></td>
                </tr>
                <tr>
                    <td><img src="do1.png"/></td>
                </tr>
                <tr>
                    <td><img src="do2.png"/></td>
                </tr>
                <tr>
                    <td><img src="expression.png"/></td>
                </tr>
                <!--
                <tr>
                    <td>
                        <table width="100%" cellpadding="0" cellspacin="0">
                            <tr style="border:1px solid black;">
                                <td class="header" >Alleles</td>
                            </tr>
                            <tr>
                                <td>
                                <table width="100%"  cellpadding="0" cellspacin="0">
                                    <tr>
                                        <td class="subHeader">Allele Symbol</td>
                                        <td class="subHeader">Allele Synonyms</td>
                                        <td class="subHeader">Associated Human Disease</td>
                                        <td class="subHeader">Associated phenotypes</td>
                                    </tr>
                                    <tr>
                                        <td class="cell"><a href="allele/">Cit<sup>fhJjlo</sup></a></td>
                                        <td class="cell">CitfhjJlo</td>
                                        <td class="cell"><li><a href="https://build.alliancegenome.org/disease/DOID:10907">microcephaly</a></li><li><a href="https://build.alliancegenome.org/disease/DOID:11832">visual epilepsy</a></li></td>
                                        <td class="cell"><li>binucleate<br>
                                            <li>decreased forebrain size<br>
                                            <li>flat head
                                        </td>
                                    </tr>
                                </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                -->
                <tr>
                    <td>

                            <table width="100%" cellpadding="0" cellspacin="0">
                                <tr>
                                    <td class="header"><br>Variants/Alleles&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a style="font-size:14px;" href="variantList">Analyze Variants/Alleles</a></td>
                                </tr>
                            </table>


                        <div style="height: 600px; overflow: auto;">


                            <table width="100%" cellpadding="6" cellspacing="0">
                                <tr>

                                    <td class="subHeader">Variant/allele symbol</td>
                                    <td class="subHeader">Type</td>
                                    <td class="subHeader">Genomic alteration</td>
                                    <td class="subHeader">Genomic alteration type</td>
                                    <td class="subHeader">Molecular consequence</td>
                                    <td class="subHeader">Has phenotype/Disease annotations</td>

                                    <!--
                                    <td class="subHeader">ID</td>
                                    <td class="subHeader">Variant/allele symbol</td>
                                    <td class="subHeader">Variant Type</td>
                                    <td class="subHeader">Chromosome:position</td>
                                    <td class="subHeader">Nucleotide Change</td>
                                    <td class="subHeader">Most Severe<br>Consequence</td>
                                    <td class="subHeader">Most Severe<br>Protein Consequence</td>
                                    -->
                                    <!--
                                    <td class="subHeader">Disease<br> Association</td>
                                    <td class="subHeader">Phenotype<br> Association</td>
                                    -->
                                </tr>

                                <tr>
                                    <td class="cell"><a href="allele/">Cit<sup>fhJjlo</sup></a></td>
                                    <td class="cell">allele with 1 known variant</td>
                                    <td class="cell">Chr23:29630700_29630700del</td>
                                    <td class="cell">deletion</td>
                                    <td class="cell">frameshift</td>
                                    <td class="cell"><a href="allele/">D</a> <a href="allele/">P</a></td>
                                </tr>
                                <tr>
                                    <td class="cell"><a href="allele/indexU.jsp">Cit<sup>fhJjlo2</sup></a></td>
                                    <td class="cell">allele with unknown variant</td>
                                    <td class="cell"></td>
                                    <td class="cell"></td>
                                    <td class="cell"></td>
                                    <td class="cell"><a href="allele/indexU.jsp">D</a></td>
                                </tr>
                                <tr>
                                    <td class="cell"><a href="allele/index2.jsp">Cit<sup>fhJjlo3</sup></a></td>
                                    <td class="cell" valign="top">allele with multiple known variant</td>
                                    <td class="cell" style="padding-top:8px;padding-bottom:8px;">Chr23:29630700_29630700del<br>Chr23:29630700_29630700del</td>
                                    <td class="cell">insertion<br>point mutation</td>
                                    <td class="cell">frameshift<br>point mutation</td>
                                    <td class="cell"><a href="allele/index2.jsp">D</a> <a href="allele/">P</a></td>
                                </tr>
                                <tr>
                                    <td class="cell"><a href="allele/indexT.jsp">Cit<sup>fhJjlo4</sup></a></td>
                                    <td class="cell">transgenic allele</td>
                                    <td class="cell"></td>
                                    <td class="cell">insertion</td>
                                    <td class="cell"></td>
                                    <td class="cell"><a href="allele/indexT.jsp">P</a></td>
                                </tr>

                                <%
                                    BufferedReader br = new BufferedReader(new StringReader(vars));
                                    String line = null;
                                %>


                                <%
                                    int i=0;
                                    while ((line=br.readLine()) != null) {
                                    i++;
                                        String[] cols = line.split(",");

                                %>
                                <tr>
                                    <td class="cell"><a href="alleleV/"><%=cols[5]%></a></td>
                                    <!--<td class="cell"><a href="variant/">HGVS Name</a></td>-->
                                    <td class="cell">variant</td>
                                    <td class="cell">Chr<%=cols[0]%>:<%=cols[1]%></td>
                                    <td class="cell"><%=cols[6]%></td>

                                    <% if (i==3 || i==5 || i==15 || i==25) { %>
                                        <td class="cell">missense</td>
                                    <% } else if (i==4 || i==9) { %>
                                        <td class="cell">stop gain</td>
                                    <% } else { %>
                                        <td class="cell">intergenic variant</td>
                                    <% }  %>

                                    <!--
                                    <% if (cols.length >=9) {%>
                                    <td class="cell"><%=cols[8]%></td>
                                    <% } else {%>
                                    <td class="cell"></td>
                                    <% } %>

                                    <% if (cols.length >=10) {%>
                                    <td class="cell"><%=cols[9]%></td>
                                    <% } else {%>
                                    <td class="cell"></td>
                                    <% } %>
                                    -->
                                    <td class="cell"></td>
                                </tr>
                                <% } %>
                            </table>
                        </div>

                    </td>
                </tr>
                <tr>
                    <td><img src="models.png"/></td>
                </tr>
                <tr>
                    <td><img src="interactions.png"/></td>
                </tr>


            </table>




        </td>
    </tr>
</table>