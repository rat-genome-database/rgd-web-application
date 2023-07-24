package edu.mcw.rgd.overgo;

import org.biojava.bio.seq.DNATools;
import org.biojava.bio.symbol.SymbolList;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Apr 27, 2011
 * Time: 1:28:47 PM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Wrapper classs for executing oligo spawn
 */
public class OligoSpawnWrapper {

    /**
     * Execute ologo spawn and return a response
     * @param osr
     * @return
     * @throws Exception
     */
 public OligoSpawnResponse execute(OligoSpawnRequest osr ) throws Exception {

            List commandOptions = new ArrayList();

            commandOptions.add("/rgd/scripts/oligospawn/oligospawn_exe/uniqOligo.exe");
            commandOptions.add(osr.getInputFile());
            commandOptions.addAll(osr.getOptions());

            ProcessBuilder pb = new ProcessBuilder(commandOptions);
            java.util.Map<String, String> env = pb.environment();
            pb.directory(new File("/rgd/scripts/oligospawn/oligospawn_exe"));
            Process p = pb.start();

            return this.buildResponse(p);
    }

    /**
     * 
     * @param process
     * @return
     * @throws Exception
     */
    private OligoSpawnResponse buildResponse(Process process) throws Exception {
        InputStreamReader tempReader = new InputStreamReader(new BufferedInputStream(process.getInputStream()));
        BufferedReader reader = new BufferedReader(tempReader);

        List<OligoSpawnResponse> retList = new ArrayList();

        OligoSpawnResponse osr = new OligoSpawnResponse();

        while (true) {
            String line = reader.readLine();
            if (line == null) {
                break;
            }

            if (line.startsWith(">")) {
                osr.setHeader(line);
            }else if (line.length() == 36) {

                osr.getForward().add(line.substring(0,22));
                SymbolList symL = DNATools.createDNA(line.substring(14,36));
                SymbolList symlComp = DNATools.reverseComplement(symL);

                osr.getReverse().add(symlComp.seqString().toUpperCase());

            }
        }

        tempReader.close();

        tempReader = new InputStreamReader(new BufferedInputStream(process.getErrorStream()));
        reader = new BufferedReader(tempReader);

        while (true) {
            String line = reader.readLine();
            if (line == null)
                break;
            osr.setError(osr.getError() + line);
        }

        return osr;
    }
}
