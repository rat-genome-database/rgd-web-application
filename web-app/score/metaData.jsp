<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %><%@ page import="java.sql.Connection" %><%@ page import="java.sql.Statement" %><%@ page import="java.sql.ResultSet" %><%
    response.setHeader("Content-Type", "text/csv");
    response.setHeader("Content-Disposition", "attachment; filename=" + "rna_seq_meta_data.txt");

    GeneDAO gdao = new GeneDAO();

    Connection conn = gdao.getConnection();

    Statement stmt = conn.createStatement();

    String query = "select distinct " +
            "       sa.SAMPLE_ID, " +
            "       sa.STRAIN_ONT_ID, " +
            "       ots.TERM as strain, " +
            "       sa.TISSUE_ONT_ID, " +
            "       ott.TERM as tissue, " +
            "       sa.AGE_DAYS_FROM_DOB_LOW_BOUND as age_in_days_low, " +
            "       sa.AGE_DAYS_FROM_DOB_HIGH_BOUND as age_in_days_high, " +
            "       sa.SEX, " +
            "       st.STUDY_ID, " +
            "       st.STUDY_SOURCE, " +
            "       st.GEO_SERIES_ACC, " +
            "       sa.GEO_SAMPLE_ACC, " +
            "       ev.EXPRESSION_UNIT " +
            "from GENE_EXPRESSION_VALUES ev " +
            "join GENE_EXPRESSION_EXP_RECORD er on er.GENE_EXPRESSION_EXP_RECORD_ID=ev.GENE_EXPRESSION_EXP_RECORD_ID " +
            "join SAMPLE sa on sa.SAMPLE_ID=er.SAMPLE_ID " +
            "join EXPERIMENT e on e.EXPERIMENT_ID=er.EXPERIMENT_ID " +
            "join STUDY st on st.STUDY_ID=e.STUDY_ID " +
            "join ONT_TERMS ots on ots.TERM_ACC=sa.STRAIN_ONT_ID " +
            "join ONT_TERMS ott on ott.TERM_ACC=sa.TISSUE_ONT_ID " +
            "where er.SPECIES_TYPE_KEY=3 " +
            "and ev.EXPRESSION_UNIT='TPM' " +
            "order by st.STUDY_ID, sa.SAMPLE_ID";


    ResultSet rs = stmt.executeQuery(query);

    out.println("sample_id,strain_ont_id,strain,tissue_ont_id,tissue,age_in_days_low,age_in_days_high,sex,study_id,study_source,geo_series_acc,geo_sample_acc,expression_unit");

    while (rs.next()) {
        out.print(rs.getString("sample_id"));
        out.print(",");
        out.print(rs.getString("strain_ont_id"));
        out.print(",");
        out.print(rs.getString("strain"));
        out.print(",");
        out.print(rs.getString("tissue_ont_id"));
        out.print(",");
        out.print(rs.getString("tissue"));
        out.print(",");
        out.print(rs.getString("age_in_days_low"));
        out.print(",");
        out.print(rs.getString("age_in_days_high"));
        out.print(",");
        out.print(rs.getString("sex"));
        out.print(",");
        out.print(rs.getString("study_id"));
        out.print(",");
        out.print(rs.getString("study_source"));
        out.print(",");
        out.print(rs.getString("geo_series_acc"));
        out.print(",");
        out.print(rs.getString("geo_sample_acc"));
        out.print(",");
        out.print(rs.getString("expression_unit"));
        out.print("\n");


    }
    conn.close();
%>