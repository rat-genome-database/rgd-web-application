package edu.mcw.rgd;

import java.io.File;
import java.io.FileReader;
import java.util.BitSet;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Dec 18, 2009
 * Time: 12:09:16 PM
 */
public class Sequencer {

    public static void main (String[] args) throws Exception {

        //System.out.println("hello world");

        String str1 = "taaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaacccaaccctaaccctaaccctaaccctaaccctaaccctaacccctaaccctaaccctaaccctaaccctaacctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaacccctaaccctaaccctaaaccctaaaccctaaccctaaccctaaccctaaccctaaccccaaccccaaccccaaccccaaccccaaccccaaccctaacccctaaccctaaccctaaccctaccctaaccctaaccctaaccctaaccctaaccctaacccctaacccctaaccctaaccctaaccctaaccctaaccctaaccctaacccctaaccct";               

        String str2 = "taaccctaaccctaaccctttccctaaccctaaccctaaccctaGAaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaacccaaccctaaccctaaccctaaccctaaccctaaccctaacccctaaccctaaccctaaccctaaccctaacctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaaccctaacccctaaccctaaccctaaaccctaaaccctaaccctaaccctaaccctaaccctaaccccaaccccaaccccaaccccaaccccaaccccaaccctaacccctaaccctaaccctaaccctaccctaaccctaaccctaaccctaaccctaaccctaacccctaacccctaaccctaaccctaaccctaaccctaaccctaaccctaacccctaaccct";


        FileReader sr = new FileReader(new File("C:\\home\\sequence\\assembly1\\chr12.fa"));


        int val = sr.read();
        int mark=2;

        BitSet bit1 = new BitSet(1000);

        while (val != -1) {
            val=sr.read();

            System.out.print((char) val);

            if (mark > 100000) break;


            switch (val) {
                        case 116:          //t 00
                             break;
                        case 97:              //a 01
                            bit1.set(mark + 1);
                            break;
                        case 99:                 //c 10
                            bit1.set(mark);
                            break;
                        case 103:                   //g 11
                            bit1.set(mark);
                            bit1.set(mark + 1);
                            break;
                        case 84:          //t 00
                             break;
                        case 65:              //a 01
                            bit1.set(mark + 1);
                            break;
                        case 67:                 //c 10
                            bit1.set(mark);
                            break;
                        case 71:                   //g 11
                            bit1.set(mark);
                            bit1.set(mark + 1);
                            break;
                        default:
                            break;
                    }

            mark = mark + 2;

        }
        //System.out.println();

        sr = new FileReader(new File("C:\\home\\sequence\\assembly2\\chr12.fa"));

        val = sr.read();
        mark=2;

        BitSet bit2 = new BitSet(1000);

        while (val != -1) {

            if (mark > 100000) break;

            val=sr.read();

            System.out.print((char) val);
            
            switch (val) {
                case 116:          //t 00
                     break;
                case 97:              //a 01
                    bit2.set(mark + 1);
                    break;
                case 99:                 //c 10
                    bit2.set(mark);
                    break;
                case 103:                   //g 11
                    bit2.set(mark);
                    bit2.set(mark + 1);
                    break;
                case 84:          //t 00
                     break;
                case 65:              //a 01
                    bit2.set(mark + 1);
                    break;
                case 67:                 //c 10
                    bit2.set(mark);
                    break;
                case 71:                   //g 11
                    bit2.set(mark);
                    bit2.set(mark + 1);
                    break;
                default: 
                    break;

                    }

            mark = mark + 2;

        }

        //System.out.println(bit1.toString());
        //System.out.println(bit2.toString());

        bit1.xor(bit2);

        //System.out.println(bit1.toString());








    }

}
