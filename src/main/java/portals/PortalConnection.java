package portals;

import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "portal";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "lbqgvo11";

    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
      

     try(PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO Registrations (student, course) VALUES (?, ?)"
            );){
         ps.setString(1, student);
         ps.setString(2, courseCode);
         int r = ps.executeUpdate();
         return "{\"success\":true, register:\""+student+"\" to course \""+courseCode+"\"}";
     } catch (SQLException e) {
          return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        try(PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM Registrations WHERE student=? AND course=?"
        )){
            ps.setString(1, student);
            ps.setString(2, courseCode);

            int r = ps.executeUpdate();

             String ret = "Deleted "+r+" registrations.";
             if(r != 0) {
                 ret = "{\"success\":true, unregister:\"" + student + "\" from course \"" + courseCode + "\"}";
             }
            return ret;
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        String query = "SELECT jsonb_build_object(" +
                "'student', idnr, " +
                "'name', name, " +
                "'login', login, " +
                "'program', program, " +
                "'branch', branch, " +
                "'finished', (SELECT jsonb_agg(jsonb_build_object('name', courseName,'course',course,'credits',credits, 'grade', grade)) " +
                "FROM FinishedCourses WHERE student = ?), " +
                "'registered', (SELECT jsonb_agg(jsonb_build_object('name',(SELECT name FROM Courses WHERE code = Registrations.course)" +
                " ,'course', course, 'status', status, 'position', (SELECT position FROM WaitingList WHERE course = Registrations.course))) " +
                  "FROM Registrations WHERE student = ? ),"+
                "'seminarCourses', (SELECT json_agg(json_build_object('Number of passed seminar courses',seminarcourses)) " +
                "FROM PathToGraduation WHERE student = ? ),"+
                "'totalCredits', (SELECT json_agg(jsonb_build_object('Total passed credits', totalCredits)) " +
                "FROM PathToGraduation WHERE student = ? ),"+
                "'canGraduate', (SELECT json_agg(jsonb_build_object('Qualified for graduation', qualified)) " +
                "FROM PathToGraduation WHERE student = ? )"+
                ") AS jsondata " +
                "FROM BasicInformation WHERE idnr = ?";
        
        try(PreparedStatement st = conn.prepareStatement(
            query
            );){
            for (int i = 1; i < 7; i++) {
                st.setString(i, student);
            }




            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}