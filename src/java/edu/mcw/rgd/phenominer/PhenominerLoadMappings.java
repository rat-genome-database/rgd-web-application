package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.AbstractDAO;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.object.SqlUpdate;

import java.sql.Types;

/**
 * Created by IntelliJ IDEA. <br>
 * User: mtutaj <br>
 * Date: 7/18/11 <br>
 * Time: 1:07 PM <br>
 * To change this template use File | Settings | File Templates.
 * <p>
 * utility class to handle loading/saving of pga mappings
 */
public class PhenominerLoadMappings extends AbstractDAO {

    /**
     * save a mapping into database
     * @param mapping mapping object to be saved into db
     * @return nr of rows affected; 0 if there is already identical mapping in db
     * @throws Exception
     */
    public int saveMapping(PhenominerLoadMapping mapping) throws Exception {

        // see first if the mapping is available
        PhenominerLoadMapping map = getMapping(mapping.getType(), mapping.getName());
        if( map==null ) {
            // new mapping has to be created, if the value is given
            if( mapping.getValue()!=null && !mapping.getValue().trim().isEmpty() )
                return insertMapping(mapping);

            return 0; // nothing to do: no mapping value, no mapping in the table
        }
        else {
            // there is a mapping in db
            //
            // 1. if value is not given, the mapping should be deleted
            if( mapping.getValue()==null || mapping.getValue().trim().isEmpty() ) {
                return deleteMapping(map);
            }

            // 2. check if values are the same
            if( map.getValue().equalsIgnoreCase(mapping.getValue()) ) {
                // yes -- there is a mapping with same value already in database -- nothing to do
                return 0;
            }
            else {
                // 3. there is a mapping in database, but with different value -- update the value
                map.setValue(mapping.getValue());
                return updateMapping(map);
            }
        }
    }

    public PhenominerLoadMapping getMapping(String type, String name) throws Exception {

        String sql = "SELECT mapping_value FROM pgaload_mappings WHERE mapping_type=? AND mapping_name=?";

        JdbcTemplate jt = new JdbcTemplate(this.getDataSource());
        String value;
        try {
            value = (String) jt.queryForObject(sql, new Object[]{type,name}, String.class);
        }
        catch(org.springframework.dao.EmptyResultDataAccessException e) {
            return null; // no such mapping
        }
        PhenominerLoadMapping map = new PhenominerLoadMapping();
        map.setType(type);
        map.setName(name);
        map.setValue(value);
        return map;
    }

    public int insertMapping(PhenominerLoadMapping mapping) throws Exception {

        String sql = "INSERT INTO pgaload_mappings (mapping_type,mapping_name,mapping_value) VALUES(?,?,?)";
        SqlUpdate su = new SqlUpdate(this.getDataSource(), sql);
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.compile();
        return su.update(new Object[]{mapping.getType(), mapping.getName(), mapping.getValue()});
    }

    public int updateMapping(PhenominerLoadMapping mapping) throws Exception {

        String sql = "UPDATE pgaload_mappings SET mapping_value=? WHERE mapping_type=? AND mapping_name=?";
        SqlUpdate su = new SqlUpdate(this.getDataSource(), sql);
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.compile();
        return su.update(new Object[]{mapping.getValue(), mapping.getType(), mapping.getName()});
    }

    public int deleteMapping(PhenominerLoadMapping mapping) throws Exception {

        String sql = "DELETE FROM pgaload_mappings WHERE mapping_type=? AND mapping_name=?";
        SqlUpdate su = new SqlUpdate(this.getDataSource(), sql);
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.declareParameter(new SqlParameter(Types.VARCHAR));
        su.compile();
        return su.update(new Object[]{mapping.getType(), mapping.getName()});
    }
}
