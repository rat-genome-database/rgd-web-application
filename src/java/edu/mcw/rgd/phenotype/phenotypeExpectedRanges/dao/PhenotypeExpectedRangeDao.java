package edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.OntologyXDAO;

import edu.mcw.rgd.dao.spring.CountQuery;
import edu.mcw.rgd.dao.spring.StringListQuery;
import edu.mcw.rgd.datamodel.ontologyx.Relation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Record;


import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.ExpectedRangePlotValues;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.ExpectedRangeRecord;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.PhenotypeObject;
import edu.mcw.rgd.process.Utils;



import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

/**
 * Created by jthota on 3/5/2018.
 */
public class PhenotypeExpectedRangeDao extends OntologyXDAO {
   StrainGroupDao sdao= new StrainGroupDao();

    public List<ExpectedRangeRecord> getPhenotypeExpectedRangeRecordsByPhenotype(String phenotype) throws Exception {
        String sql= "SELECT * FROM EXPECTED_RANGE WHERE TRAIT_ONT_ID=? ";
        try(Connection conn= DataSourceFactory.getInstance().getDataSource().getConnection()){
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1,phenotype);

            ResultSet rs=    stmt.executeQuery();
            List<ExpectedRangeRecord> records= new ArrayList<>();
            int i=1;
            while(rs.next()){
                ExpectedRangeRecord er= new ExpectedRangeRecord();
                er.setId(i);
                er.setStrainGroupId(rs.getInt("strain_group_id"));
                er.setExpectedRangeName(rs.getString("expected_range_name"));
                er.setStrainGroupName(sdao.getStrainGroupName(rs.getInt("strain_group_id")));
                er.setClinicalMeasurement(phenotype);
                er.setClinicalMeasurementAccId(rs.getString("clinical_measurement_ont_id"));
                er.setMeasurementMethodGroupId(rs.getString("measurement_method_ont_id"));
                er.setAgeLowBound(rs.getString("AGE_DAYS_FROM_DOB_LOW_BOUND"));
                er.setAgeHighBound(rs.getString("AGE_DAYS_FROM_DOB_HIGH_BOUND"));
                er.setSex(rs.getString("SEX"));
                er.setGroupValue(rs.getDouble("GROUP_VALUE"));
                er.setGroupLow(rs.getDouble("GROUP_LOW"));  // there is mismatch between column names and data in database.
                er.setGroupHigh(rs.getDouble("Group_High"));
                er.setGroupSD(rs.getDouble("group_sd"));
                String methodId=rs.getString("measurement_method_ont_id");
               List<String> methodIds= new ArrayList<>(Arrays.asList(methodId.split(",")));

                List<String> methods= new ArrayList<>();
                for(String m:methodIds){
                    String method=getTerm(m).getTerm();
                    if(!methods.contains(method))
                        methods.add(method);
                }
                er.setMeasurementMethodTerms(methods);
                er.setMethodAccIds(methodIds);
                er.setUnits(rs.getString("group_units"));
                i++;
                records.add(er);
           /*     System.out.println(rs.getString("TRAIT_ONT_ID")+"\t"+rs.getString("CONDITION_GROUP_ID")+"\t"+rs.getString("CLINICAL_MEASUREMENT_ONT_ID")
               +"\t"+rs.getString("MEASUREMENT_METHOD_ONT_ID")+"\t"+
               rs.getString("STRAIN_GROUP_ID")+"\t"+
               rs.getString("SEX")+"\t"+
               rs.getString("GROUP_VALUE")+"\t"+
              rs.getString("GROUP_SD")+"\t"+
               rs.getString("GROUP_LOW")+"\t"+
               rs.getString("GROUP_HIGH"));*/
            }
            records.sort(new Comparator<ExpectedRangeRecord>() {
                @Override
                public int compare(ExpectedRangeRecord o1, ExpectedRangeRecord o2) {
                   return Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(), o2.getStrainGroupName());
                }

            });

            return records;
        }catch (Exception e){

        }
       return null;
    }


    public List<ExpectedRangeRecord> getPhenotypeExpectedRangeRecordsByPhenotype(String phenotype, List<Integer> strainGroupIds, List<String> sex, List<Integer> ageLow, List<Integer> ageHigh, List<String> selectedMethods) throws Exception {

        String sql= "SELECT * FROM EXPECTED_RANGE WHERE TRAIT_ONT_ID=? ";
        sql+=this.buildIntQuery(strainGroupIds, "strain_group_id");
        sql+=this.buildIntQuery(ageLow, "AGE_DAYS_FROM_DOB_LOW_BOUND");
        sql+=this.buildIntQuery(ageHigh,"AGE_DAYS_FROM_DOB_HIGH_BOUND");
       sql+=this.buildStringQuery(sex, "SEX");
        System.out.println("SELECTED METHODS SIZE:" + selectedMethods.size());
        String methodQuery=this.buildMethodQuery(selectedMethods, "measurement_method_ont_id");
        if(methodQuery!=null)
        sql+=methodQuery;



        System.out.println(sql);
        try(Connection conn= DataSourceFactory.getInstance().getDataSource().getConnection()){
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1,phenotype);

            ResultSet rs=    stmt.executeQuery();
            List<ExpectedRangeRecord> records= new ArrayList<>();
            int i=1;
            while(rs.next()){
                ExpectedRangeRecord er= new ExpectedRangeRecord();
              //  er.setId(i);
                er.setId(rs.getInt("expected_range_id"));
                er.setStrainGroupId(rs.getInt("strain_group_id"));
                er.setStrainGroupName(sdao.getStrainGroupName(rs.getInt("strain_group_id")));
                er.setExpectedRangeName(rs.getString("expected_range_name"));
                er.setClinicalMeasurement(phenotype);
                er.setClinicalMeasurementAccId(rs.getString("clinical_measurement_ont_id"));
                er.setMeasurementMethodGroupId(rs.getString("measurement_method_ont_id"));
                er.setAgeLowBound(rs.getString("AGE_DAYS_FROM_DOB_LOW_BOUND"));
                er.setAgeHighBound(rs.getString("AGE_DAYS_FROM_DOB_HIGH_BOUND"));
                er.setSex(rs.getString("SEX"));
                er.setGroupValue(rs.getDouble("GROUP_VALUE"));
                er.setGroupLow(rs.getDouble("GROUP_low"));  // there is mismatch between column names and data in database.
                er.setGroupHigh(rs.getDouble("Group_high"));
                er.setGroupSD(rs.getDouble("group_sd"));

                String methodId=rs.getString("measurement_method_ont_id");
                List<String> methodIds= new ArrayList<>(Arrays.asList(methodId.split(",")));

                List<String> methods= new ArrayList<>();

                for(String m:methodIds){
                    String method=getTerm(m).getTerm();
                    if(!methods.contains(method))
                        methods.add(method);
                }
                er.setMethodAccIds(methodIds);
                er.setMeasurementMethodTerms(methods);
                er.setUnits(rs.getString("group_units"));
                i++;
                records.add(er);

            }
            records.sort(new Comparator<ExpectedRangeRecord>() {
                @Override
                public int compare(ExpectedRangeRecord o1, ExpectedRangeRecord o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(), o2.getStrainGroupName());
                }

            });

            return records;
        }catch (Exception e){
                e.printStackTrace();
        }
        return null;
    }


    public String buildIntQuery(List<Integer> values, String field){
        String sql= new String();
        if(values!=null){
            if(values.size()>0){
                sql+=" and "+field +" in (";

            boolean first=true;
            for(int i:values){
                if(first){
                    sql+=i;
                    first=false;
                }else{
                    sql+=","+i;
                }


            }
            sql+=")";
            }
        }
        return sql;
    }
    public String buildStringQuery(List<String> strs, String field){
        String sql= new String();
        if(strs!=null){
            if(strs.size()>0){
                sql+=" and "+field +" in (";
                boolean first=true;
                for(String s:strs){
                    if(first){
                        sql+="'"+s +"'";
                        first=false;
                    }else{
                        sql+=","+"'"+s+"'";
                    }
                }
                sql+=")";
            }

        }
        return sql;
    }

    public String buildMethodQuery(List<String> strs, String field){
        String sql= new String();
        if(strs.size()==3){
                return null;
        }
        if(strs!=null) {
            if (strs.size() > 0 ) {

                if(strs.contains("mixed")){
                    sql+=" and "+ field +" not in (";
                    for(String s:strs){
                        if(s.equalsIgnoreCase("mixed")){

                            if(!strs.contains("vascular") && !strs.contains("tail")){


                                sql +=  " 'MMO:0000011' , 'MMO:0000031' )";

                            }else{
                                if(strs.contains("vascular")){


                                    sql +=  " 'MMO:0000031' )";
                                }
                                if(strs.contains("tail")){


                                    sql +=  " 'MMO:0000011' )";
                                }
                            }

                        }
                    }

                }else{
                    if(strs.contains("vascular") || strs.contains("tail")) {
                        sql += " and " + field + " in (";
                        boolean first = false;
                        for (String s : strs) {
                            if (s.equalsIgnoreCase("vascular") || s.equalsIgnoreCase("tail")) {
                                if (s.equalsIgnoreCase("vascular")) {
                                    if (!first) {
                                        sql += " '" + "MMO:0000011" + "' ";
                                        first = true;
                                    } else {
                                        sql += " , '" + "MMO:0000011" + "' ";
                                    }
                                }
                                if (s.equalsIgnoreCase("tail")) {
                                    if (!first) {
                                        sql += " '" + "MMO:0000031" + "' ";
                                        first = true;
                                    } else {
                                        sql += " , '" + "MMO:0000031" + "' ";
                                    }
                                }


                            }
                        }
                        sql += ")";
                    }
                }


                }


        }
        return sql;
    }
    public int getDistinctPhenotypeCountByStrainGroupId(String strainGoupId) throws Exception {
        String sql="select count(distinct(trait_ont_id)) from expected_range where strain_group_id="+strainGoupId;

        CountQuery q= new CountQuery(this.getDataSource(), sql);
        return q.getCount();

    }

    public List<String> getDistinctPhenotypesByStrainGroupId(String strainGoupId) throws Exception {
        String sql="select distinct(clinical_measurement_ont_id) from expected_range where strain_group_id="+strainGoupId;
        StringListQuery q= new StringListQuery(this.getDataSource(), sql);
        return q.execute();

    }
   public List<ExpectedRangeRecord> getPhenotypeExpectedRangeRecordsByStrainGroupId(String strainGroupId){
       String sql= "SELECT * FROM EXPECTED_RANGE WHERE Strain_group_id=? ";
       try(Connection conn= DataSourceFactory.getInstance().getDataSource().getConnection()){
           PreparedStatement stmt = conn.prepareStatement(sql);
           stmt.setString(1,strainGroupId);

           ResultSet rs=    stmt.executeQuery();
           List<ExpectedRangeRecord> records= new ArrayList<>();
           int i=1;
           while(rs.next()){
               ExpectedRangeRecord er= new ExpectedRangeRecord();
               er.setId(i);
               er.setStrainGroupId(rs.getInt("strain_group_id"));
               er.setExpectedRangeName(rs.getString("expected_range_name"));
              // er.setStrainGroupName(strainGroupId);
               er.setStrainGroupName(sdao.getStrainGroupName(Integer.parseInt(strainGroupId)));
               er.setClinicalMeasurement(rs.getString("trait_ont_id"));
               er.setClinicalMeasurementAccId(rs.getString("clinical_measurement_ont_id"));
               er.setMeasurementMethodGroupId(rs.getString("measurement_method_ont_id"));
               er.setAgeLowBound(rs.getString("AGE_DAYS_FROM_DOB_LOW_BOUND"));
               er.setAgeHighBound(rs.getString("AGE_DAYS_FROM_DOB_HIGH_BOUND"));
               er.setSex(rs.getString("SEX"));
               er.setGroupValue(rs.getDouble("GROUP_VALUE"));
               er.setGroupLow(rs.getDouble("GROUP_LOW"));  // there is mismatch between column names and data in database.
               er.setGroupHigh(rs.getDouble("Group_High"));
               er.setGroupSD(rs.getDouble("group_sd"));
                i++;
               records.add(er);
           /*     System.out.println(rs.getString("TRAIT_ONT_ID")+"\t"+rs.getString("CONDITION_GROUP_ID")+"\t"+rs.getString("CLINICAL_MEASUREMENT_ONT_ID")
               +"\t"+rs.getString("MEASUREMENT_METHOD_ONT_ID")+"\t"+
               rs.getString("STRAIN_GROUP_ID")+"\t"+
               rs.getString("SEX")+"\t"+
               rs.getString("GROUP_VALUE")+"\t"+
              rs.getString("GROUP_SD")+"\t"+
               rs.getString("GROUP_LOW")+"\t"+
               rs.getString("GROUP_HIGH"));*/
           }
           records.sort(new Comparator<ExpectedRangeRecord>() {
               @Override
               public int compare(ExpectedRangeRecord o1, ExpectedRangeRecord o2) {
                   return Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(), o2.getStrainGroupName());
               }

           });

           return records;
       }catch (Exception e){

       }
       return null;
   }
    public List<String> getDistinctPhenotypes() throws Exception {
        String sql= "select distinct(TRAIT_ONT_ID) from expected_range";
        StringListQuery query= new StringListQuery(this.getDataSource(),sql);
       return query.execute();
    }
    public List<String> getDistinctStrainGroups() throws Exception {
        String sql= "select distinct(STRAIN_GROUP_ID) from expected_range";
        StringListQuery query= new StringListQuery(this.getDataSource(),sql);
        return query.execute();
    }
    public List<String> getDistinctStrainsOfPhenotype(String phenotype) throws Exception {
        String sql= "select count(distinct(strain_group_id)) from expected_range where trait_ont_id=" + "'"+phenotype+"'";
        StringListQuery query= new StringListQuery(this.getDataSource(),sql);
        return query.execute();
    }
    public List<String> getStrainRecords(int strain_group_id) throws Exception {
        String sql= "select strain_ont_id from expected_range where strain_group_id="+"'"+strain_group_id+"'";
        StringListQuery query= new StringListQuery(this.getDataSource(),sql);
        return query.execute();
    }
    public List<ExpectedRangeRecord> getExpectedRangeRecordsOfDistinctAge(String phenotype){
        String sql= "SELECT distinct(age) FROM EXPECTED_RANGE WHERE TRAI_ONT_ID=?  ";
        try(Connection conn= DataSourceFactory.getInstance().getDataSource().getConnection()){
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1,phenotype);

            ResultSet rs= null;
            rs=    stmt.executeQuery();
            List<ExpectedRangeRecord> records= new ArrayList<>();
            int i=1;
            while(rs.next()){
                ExpectedRangeRecord er= new ExpectedRangeRecord();
                er.setId(i);
                er.setStrainGroupId(rs.getInt("strain_group_id"));
                er.setClinicalMeasurement(phenotype);
                er.setClinicalMeasurementAccId(rs.getString("clinical_measurement_ont_id"));
                er.setMeasurementMethodGroupId(rs.getString("measurement_method_ont_id"));
                er.setAgeLowBound(rs.getString("AGE_DAYS_FROM_DOB_LOW_BOUND"));
                er.setAgeHighBound(rs.getString("AGE_DAYS_FROM_DOB_HIGH_BOUND"));
                er.setSex("SEX");
                er.setGroupValue(rs.getDouble("GROUP_VALUE"));
                er.setGroupLow(rs.getDouble("GROUP_LOW"));
                er.setGroupHigh(rs.getDouble("Group_high"));
                er.setGroupSD(rs.getDouble("group_sd"));
                i++;
                records.add(er);
           /*     System.out.println(rs.getString("TRAIT_ONT_ID")+"\t"+rs.getString("CONDITION_GROUP_ID")+"\t"+rs.getString("CLINICAL_MEASUREMENT_ONT_ID")
                        +"\t"+rs.getString("MEASUREMENT_METHOD_ONT_ID")+"\t"+
                        rs.getString("TRAIT_ONT_ID")+"\t"+
                        rs.getString("TRAIT_ONT_ID")+"\t"+
                        rs.getString("TRAIT_ONT_ID")+"\t"+
                        rs.getString("TRAIT_ONT_ID")+"\t"+
                        rs.getString("TRAIT_ONT_ID")+"\t"+
                        rs.getString("TRAIT_ONT_ID"));*/
            }
            return records;
        }catch (Exception e){

        }
        return null;
    }
    public int getExpectedRangeRecordsCountBySex(List<ExpectedRangeRecord> records){
        int i=0;

        Set<Integer> strainGroupIds= new HashSet<>();
      for(ExpectedRangeRecord record:records){
          if(!record.getStrainGroupName().contains("normal")){
              strainGroupIds.add(record.getStrainGroupId());
          }

      }
     nextId:   for(int id:strainGroupIds){
         int count=0;
         boolean maleFlag= false;
         boolean femaleFlag=false;
         boolean mixedFlag=false;
            for(ExpectedRangeRecord r:records){
                if(r.getStrainGroupId()==id){
                    if(r.getSex().equalsIgnoreCase("male") || r.getSex().equalsIgnoreCase("female")|| r.getSex().equalsIgnoreCase("mixed")) {
                        if (!maleFlag) {
                            if (r.getSex().equalsIgnoreCase("male")) {
                                count++;
                                maleFlag = true;
                            }
                        }
                        if (!femaleFlag) {
                            if (r.getSex().equalsIgnoreCase("female")) {
                                count++;
                                femaleFlag = true;
                            }
                        }
                        if (!mixedFlag) {
                            if (r.getSex().equalsIgnoreCase("mixed")) {
                                count++;
                                mixedFlag = true;
                            }
                        }

                    }
                    if(count>=2){
                            i++;
                            continue nextId;
                        }


                }
            }
        }

        return i;
    }
    public int getExpectedRangeRecordsCountByAge(List<ExpectedRangeRecord> records){
        int i=0;
        Set<Integer> strainGroupIds= new HashSet<>();
        for(ExpectedRangeRecord record:records){
            if(!record.getStrainGroupName().contains("normal")){
                strainGroupIds.add(record.getStrainGroupId());
            }

        }
     nextId:   for(int id:strainGroupIds) {
         int count=0;
         boolean age1=false;
         boolean age2=false;
         boolean age3=false;
         boolean age4=false;
            for (ExpectedRangeRecord record : records) {
                if(record.getStrainGroupId()==id){

                        if (((Integer.parseInt(record.getAgeLowBound()) >= 0 && Integer.parseInt(record.getAgeHighBound()) <= 79)) ||
                                ((Integer.parseInt(record.getAgeLowBound()) >= 80 && Integer.parseInt(record.getAgeHighBound()) <= 99)) ||
                                ((Integer.parseInt(record.getAgeLowBound()) >= 100 && Integer.parseInt(record.getAgeHighBound()) <= 999)) ||
                                ((Integer.parseInt(record.getAgeLowBound()) == 0 && Integer.parseInt(record.getAgeHighBound()) == 999))){
                            if(!age1) {
                                if (((Integer.parseInt(record.getAgeLowBound()) >= 0 && Integer.parseInt(record.getAgeHighBound()) <= 79))) {
                                    count++;
                                    age1 = true;
                                }
                            }
                            if(!age2) {
                                if (((Integer.parseInt(record.getAgeLowBound()) >= 80 && Integer.parseInt(record.getAgeHighBound()) <= 99))) {
                                    count++;
                                    age2 = true;
                                }
                            }
                            if(!age3) {
                                if (((Integer.parseInt(record.getAgeLowBound()) >=100 && Integer.parseInt(record.getAgeHighBound()) <= 999))) {
                                    count++;
                                    age3 = true;
                                }
                            }
                            if(!age4) {
                                if (((Integer.parseInt(record.getAgeLowBound()) == 0 && Integer.parseInt(record.getAgeHighBound()) == 999))) {
                                    count++;
                                    age4 = true;
                                }
                            }
                        if(count>=2){
                            i++;
                            continue nextId;
                        }

                    }

                }

            }
        }
        return i;
    }
    public List<String> getDistinctStrainGroups(List<ExpectedRangeRecord> records) throws Exception {
        Set<Integer> strainGroupIds= new HashSet<>();
        for(ExpectedRangeRecord r:records){
            strainGroupIds.add(r.getStrainGroupId());
        }
        List<String> strainGroups= new ArrayList<>();
        for(int id:strainGroupIds){
            strainGroups.add(sdao.getStrainGroupName(id));
        }
        strainGroups.sort(new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                return Utils.stringsCompareToIgnoreCase(o1, o2);
            }
        });
        return strainGroups;
    }

    public List<Term> getConditons(String termAcc) throws Exception {

        List<String> conditions=new ArrayList<>();
        List<Term> xcoTerms=getAllActiveTermDescendants(termAcc);
        conditions.add(termAcc);
        for(Term t: xcoTerms){

            conditions.add(t.getAccId());
        }
        conditions.add(termAcc);
        xcoTerms.add(getTerm(termAcc));
        xcoTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        return xcoTerms;
    }

    public List<Term> getMeasurementMethods(String termAcc) throws Exception {

        List<String> methods= new ArrayList<>();
        List<Term> mmoTerms= getAllActiveTermDescendants(termAcc);
        for(Term p: mmoTerms){

            methods.add(p.getAccId());
        }
        methods.add(termAcc);
        mmoTerms.add(getTerm(termAcc));
        mmoTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        return mmoTerms;
    }
    public List<ExpectedRangePlotValues> getPlotData(List<ExpectedRangeRecord> records, String recordType) throws Exception {
        List<ExpectedRangePlotValues> plotData=new ArrayList<>();
        if(records!=null) {
            for (ExpectedRangeRecord r : records) {
                ExpectedRangePlotValues trace = new ExpectedRangePlotValues();
                int strainGroupId = r.getStrainGroupId();
                String strainGroup = sdao.getStrainGroupName(strainGroupId);
                if(!strainGroup.contains("normal")){
                   // strainGroup="Normal Strain";

                List<Double> y = new ArrayList<>();

                y.add(r.getGroupHigh());
                //     y.add(r.getGroupSD());
                y.add(r.getGroupValue());
                y.add(r.getGroupLow());
                trace.setY(y);
                if(recordType.equalsIgnoreCase("phenotype"))
                trace.setName(r.getId()+". "+strainGroup + "- [Sex:" + r.getSex() + " - Age:" + r.getAgeLowBound() + "-" + r.getAgeHighBound() + " days" +"]");
                if(recordType.equalsIgnoreCase("strain"))
                    trace.setName(r.getExpectedRangeName());
                trace.setType("box");

                plotData.add(trace);
            }
            }
        }
        return plotData;
    }
    public Collection[] split(List<String> rsids, int size) throws Exception{
        int numOfBatches=(rsids.size()/size)+1;
        Collection[] batches= new Collection[numOfBatches];
        for(int index=0; index<numOfBatches; index++){
            int count=index+1;
            int fromIndex=Math.max(((count-1)*size),0);
            int toIndex=Math.min((count*size), rsids.size());
            batches[index]= rsids.subList(fromIndex, toIndex);
        }
        return batches;
    }


    public PhenotypeObject getPhenotypeObjectProperties1(List<String> conditionAccIds, List<String> methodAccIds, List<Integer> strainGroupIds ,List<String> clinicalMeasurementAccIds) throws Exception {

        List<Term> strains = new ArrayList<>();
        List<Term> conditions = new ArrayList<>();
        List<Term> methods = new ArrayList<>();
        PhenotypeObject object = new PhenotypeObject();

        for (int id : strainGroupIds) {
            List<String> rsIds = new ArrayList<>();
            List<Record> records = new ArrayList<>();
            rsIds.addAll(sdao.getStrainsOfStrainGroup(id));

            records = sdao.getFullRecords(rsIds, methodAccIds, clinicalMeasurementAccIds, conditionAccIds, 3);
            for (Record r : records) {
                String strainAccId = r.getSample().getStrainAccId();
                Term rsTerm=getTerm(strainAccId);
                Term methodTerm = getTerm(r.getMeasurementMethod().getAccId());

            }
        }
        return null;
    }
    public Map<String, List<String>> getPhenotypeObjectProperties(List<String> conditionAccIds, List<String> methodAccIds, List<Integer> strainGroupIds ,List<String> clinicalMeasurementAccIds) throws Exception {

       List<String> strains= new ArrayList<>();
        List<String> strainAccIds= new ArrayList<>();
        List<String> conditions= new ArrayList<>();
        List<String> methods= new ArrayList<>();

        Map<String, List<String>> optionsMap= new HashMap<>();
        List<String> rsIds=new ArrayList<>();
        List<Record> records=new ArrayList<>();
       for(int id:strainGroupIds){
             rsIds.addAll(sdao.getStrainsOfStrainGroup(id));
       }
        Collection[] collections= this.split(rsIds, 1000);
        for(int i=0;i<collections.length;i++){
            List<String> rsIdsSubList= (List<String>) collections[i];
            records .addAll(sdao.getFullRecords(rsIdsSubList,methodAccIds,clinicalMeasurementAccIds,conditionAccIds,3));
        }
            for(Record r: records){
                String strainAccId= r.getSample().getStrainAccId();
                String strain=getTerm(r.getSample().getStrainAccId()).getTerm();
            //    String method=getTerm(r.getMeasurementMethod().getAccId()).getAccId();
                if(!strains.contains(strain))
                strains.add(strain);
                if(!strainAccIds.contains(strainAccId)){
                    strainAccIds.add(strainAccId);
                }
          /*      for(String s: this.getConditions(r.getConditionGroupId())){
                    if(!conditions.contains(s)){
                        conditions.add(s);
                    }
                }

                if(!methods.contains(method))
                methods.add(method);
*/
            }

        strains.sort(new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                return Utils.stringsCompareToIgnoreCase(o1, o2);
            }
        });
        optionsMap.put("strainAccIds", strainAccIds);
        optionsMap.put("strains", strains);
   //     optionsMap.put("methods", methods);
   //     optionsMap.put("conditions", conditions);


        return optionsMap;
    }

    public List<ExpectedRangeRecord> getExpectedRangeRecord(List<String> conditionAccIds, List<String> methodAccIds, List<Integer> strainGroupIds ,List<String> clinicalMeasurementAccIds) throws Exception {

        List<String> strains= new ArrayList<>();
        List<String> strainAccIds= new ArrayList<>();
        List<String> conditions= new ArrayList<>();
        List<String> methods= new ArrayList<>();

        Map<String, List<String>> optionsMap= new HashMap<>();

        List<Record> records=new ArrayList<>();
        for(int id:strainGroupIds){
            ExpectedRangeRecord expRecord= new ExpectedRangeRecord();
            expRecord.setClinicalMeasurementAccId(clinicalMeasurementAccIds.get(0));
            expRecord.setClinicalMeasurement(getTerm(clinicalMeasurementAccIds.get(0)).getTerm());

            List<String> rsIds=new ArrayList<>();
            rsIds.addAll(sdao.getStrainsOfStrainGroup(id));

        Collection[] collections= this.split(rsIds, 1000);
        for(int i=0;i<collections.length;i++){
            List<String> rsIdsSubList= (List<String>) collections[i];
            records .addAll(sdao.getFullRecords(rsIdsSubList,methodAccIds,clinicalMeasurementAccIds,conditionAccIds,3));
        }
        for(Record r: records){
            String strainAccId= r.getSample().getStrainAccId();
            String strain=getTerm(r.getSample().getStrainAccId()).getTerm();
        //    String method=getTerm(r.getMeasurementMethod().getAccId()).getAccId();
        //    List<String> expConditions=this.getConditions(r.getConditionGroupId());
            if(!strains.contains(strain))
                strains.add(strain);
            if(!strainAccIds.contains(strainAccId)){
                strainAccIds.add(strainAccId);
            }
         /*   for(String s: this.getConditions(r.getConditionGroupId())){
                if(!conditions.contains(s)){
                    conditions.add(s);
                }
            }

            if(!methods.contains(method))
                methods.add(method);*/

        }

        }
        strains.sort(new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                return Utils.stringsCompareToIgnoreCase(o1, o2);
            }
        });
        optionsMap.put("strainAccIds", strainAccIds);
        optionsMap.put("strains", strains);
    //    optionsMap.put("methods", methods);
    //    optionsMap.put("conditions", conditions);


        return null;
    }
   public List<String> getConditions(int conditionId) throws Exception {
        List<String> conditions= new ArrayList<>();
        List<Condition> conditionList=(sdao.getConditions(conditionId));
        for(Condition c: conditionList){
            String condition=getTerm(c.getOntologyId()).getAccId();
            if(!conditions.contains(condition))
            conditions.add(condition);
        }
        return conditions;
    }

    public PhenotypeObject getPhenotypeObject(List<ExpectedRangeRecord> records, List<String> methodAccIds, List<String> conditionAccIds) throws Exception {
        PhenotypeObject object= new PhenotypeObject();

        if(methodAccIds.size()==0) {
            //   List<Term> methods= getMeasurementMethods("MMO:0000011"); //vascular indwelling catheter method
            List<Term> methods = getMeasurementMethods("MMO:0000000"); // All measurement methods

            for (Term t : methods) {
                methodAccIds.add(t.getAccId());
            }
        }
        if(conditionAccIds.size()==0){
            List<Term> condtions = getConditons("XCO:0000099"); // ACC_ID of CONTROL CONDITION
            for (Term t : condtions) {
                conditionAccIds.add(t.getAccId());
            }
        }

        List<String> strains= new ArrayList<>();
        List<String> strainAccIds= new ArrayList<>();
        List<String> xcoTerms= new ArrayList<>();
        List<String> mmoTerms= new ArrayList<>();
        List<String> sex= new ArrayList<>();
        Map<String, Integer> strainGroupIdMap=new TreeMap<>();
        List<Integer> strainGroupIds=new ArrayList<>();
        List<String> cmoAccIds= new ArrayList<>();
        for(ExpectedRangeRecord r:records){
            if(!sdao.getStrainGroupName(r.getStrainGroupId()).contains("normal")) {
                strainGroupIds.add(r.getStrainGroupId());
                strainGroupIdMap.put(sdao.getStrainGroupName(r.getStrainGroupId()), r.getStrainGroupId());
            }

        }
        cmoAccIds.add(records.get(0).getClinicalMeasurementAccId());
            Map<String, List<String>> optionsMap= getPhenotypeObjectProperties(conditionAccIds,methodAccIds,strainGroupIds,cmoAccIds);

            for(Map.Entry e: optionsMap.entrySet()){
                String key= (String) e.getKey();
                List<String> value= (List) e.getValue();
                if(key.equals("strains")){
                    for(String s: value){
                        if(!strains.contains(s))
                            strains.add(s);
                    }
                }
                if(key.equals("strainAccIds")){
                    for(String s: value){
                        if(!strainAccIds.contains(s))
                            strainAccIds.add(s);
                    }
                }
           /*     if(key.equals("methods")){
                    for(String s:value){
                        if(!mmoTerms.contains(s)){
                            mmoTerms.add(s);
                        }
                    }

                }
                if(key.equals("conditions")){
                    for(String s: value){
                        if(!xcoTerms.contains(s)){
                            xcoTerms.add(s);
                        }
                    }

                }
                if(key.equals("sex")){
                    for(String s: value){
                        if(!sex.contains(s)){
                            sex.add(s);
                        }
                    }

                }*/
            }


        /******************************************************************************************/

        List<Term> conditionTerms= new ArrayList<>();
        List<Term> methodTerms= new ArrayList<>();
        List<Term> ratStrainTerms= new ArrayList<>();


    /*    for(String s: mmoTerms){
            methodTerms.add(getTerm(s));
        }
        for(String s: xcoTerms){
            conditionTerms.add(getTerm(s));
        }*/
        for(String id:strainAccIds){
            ratStrainTerms.add(getTerm(id));
        }
        ratStrainTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        methodTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });

        conditionTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });

 //       object.setCondtionTerms(conditionTerms);
        object.setMethodTerms(methodTerms);
        /****************************************************************************************/
        object.setStrainGroupIdMap(strainGroupIdMap);
  //      object.setXcoTerms(xcoTerms);
   //     object.setMmoTerms(mmoTerms);
        object.setStrainsSymbolsOfGroup(strains);
        object.setSex(sex);
        object.setRatStrainTerms(ratStrainTerms);
        return object;
    }


    public PhenotypeObject getStrainPhenotypeObject(List<ExpectedRangeRecord> records, List<String> methodAccIds, List<String> conditionAccIds, List<Integer> strainGroupIds, List<String> cmoAccIds) throws Exception {
        PhenotypeObject object= new PhenotypeObject();

        if(methodAccIds.size()==0) {
       //   List<Term> methods= getMeasurementMethods("MMO:0000011"); //vascular indwelling catheter method
            List<Term> methods = getMeasurementMethods("MMO:0000000"); // All measurement methods

            for (Term t : methods) {
                methodAccIds.add(t.getAccId());
            }
        }
        if(conditionAccIds.size()==0){
            List<Term> condtions = getConditons("XCO:0000099"); // ACC_ID of CONTROL CONDITION
            for (Term t : condtions) {
                conditionAccIds.add(t.getAccId());
            }
        }
        List<String> strains= new ArrayList<>();
        List<String> xcoTerms= new ArrayList<>();
        List<String> mmoTerms= new ArrayList<>();

        List<String> sex= new ArrayList<>();
        Map<String, Integer> strainGroupIdMap=new TreeMap<>();

        Map<String, List<String>> optionsMap= getPhenotypeObjectProperties(conditionAccIds,methodAccIds,strainGroupIds,cmoAccIds);
            for(Map.Entry e: optionsMap.entrySet()){
                String key= (String) e.getKey();
                List<String> value= (List) e.getValue();
                if(key.equals("strains")){
                    for(String s: value){
                        if(!strains.contains(s))

                            strains.add(s);
                    }
                }
                if(key.equals("methods")){
                    for(String s:value){
                        if(!mmoTerms.contains(s)){
                            mmoTerms.add(s);

                        }
                    }

                }
                if(key.equals("conditions")){
                    for(String s: value){
                        if(!xcoTerms.contains(s)){
                            xcoTerms.add(s);

                        }
                    }

                }
                if(key.equals("sex")){
                    for(String s: value){
                        if(!sex.contains(s)){
                            sex.add(s);

                        }
                    }

                }
            }


        /******************************************************************************************/

        List<Term> conditionTerms= new ArrayList<>();
        List<Term> methodTerms= new ArrayList<>();



        for(String s: mmoTerms){
            methodTerms.add(getTerm(s));
        }
        for(String s: xcoTerms){
            conditionTerms.add(getTerm(s));
        }
        methodTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });

        conditionTerms.sort(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });

        object.setCondtionTerms(conditionTerms);
        object.setMethodTerms(methodTerms);
        /****************************************************************************************/
        object.setStrainGroupIdMap(strainGroupIdMap);
        object.setXcoTerms(xcoTerms);
        object.setMmoTerms(mmoTerms);
        object.setStrainsSymbolsOfGroup(strains);
        object.setSex(sex);
        return object;
    }

    public Map<String, String> getTraits() throws Exception {
        String rootTerm= getRootTerm("VT");
        Map<String, String> traitMap= new TreeMap<>();
        Map<String, Relation> descendants= getTermDescendants("VT:0015074");


        for(Map.Entry e: descendants.entrySet()){
          //  System.out.println(e.getKey()+"\t"+ getTerm(e.getKey().toString()).getTerm()+"\t"+ e.getValue());
            traitMap.put(getTerm(e.getKey().toString()).getTerm(),e.getKey().toString());
        }

        return traitMap;
    }
    public ExpectedRangeRecord getPhenotypeExpectedRangeRecordNormal(List<ExpectedRangeRecord> records, String sex){
        for(ExpectedRangeRecord r:records){
            ExpectedRangeRecord normalStrain= new ExpectedRangeRecord();

            if(r.getExpectedRangeName().contains("normalStrain")){
                if(r.getSex().equalsIgnoreCase(sex) && r.getAgeLowBound().equals("0") && r.getAgeHighBound().equals("999")){
                    normalStrain.setGroupValue(r.getGroupValue());
                    normalStrain.setGroupLow(r.getGroupLow());
                    normalStrain.setGroupHigh(r.getGroupHigh());
                    return normalStrain;
                }

            }


        }
        return null;
    }
}
