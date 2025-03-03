
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "AssignmentDB";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

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
      
      String queryString = "INSERT INTO Registrations VALUES ('" + student + "', '" + courseCode + "')";
      try(PreparedStatement insertQuery = conn.prepareStatement(queryString)) 
      {
          int rowsAffected = insertQuery.executeUpdate(); 
          System.out.println(rowsAffected + " row(s) affected.");
          return "{\"success\":true\"}";
      } catch (SQLException e) 
      {
          return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }      
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
      
      String queryString = "DELETE FROM Registrations WHERE student='" + student + "' AND course='" + courseCode + "'";
      try (PreparedStatement deleteQuery = conn.prepareStatement(queryString)) 
      {
          int rowsAffected = deleteQuery.executeUpdate();
          if(rowsAffected == 0) return "Student is not in Registered/WaitingList";
          return "{\"success\":true\"}";
      } catch (SQLException e) 
      {
        return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT jsonb_build_object(" +
                      "'student', b.idnr,"+
                      "'name', b.name, " +
                      "'login', (SELECT Students.login FROM Students WHERE Students.idnr = b.idnr), " +
                      "'program', b.program, " +
                      "'branch', b.branch, " +
                      "'finished', COALESCE(( " +
                              "SELECT jsonb_agg(jsonb_build_object("+
                                        "'course', f.courseName, " +
                                        "'code', f.course, " +
                                        "'credits', f.credits, " +
                                        "'grade', f.grade " +
                                        ")) FROM FinishedCourses f WHERE f.student = b.idnr), '[]'::jsonb),"+
                      "'registered', COALESCE(( " +
                              "SELECT jsonb_agg(jsonb_build_object(" +
                                        "'course', Courses.name, " +
                                        "'code', r.course, " +
                                        "'status', r.status, " +
                                        "'position', w.position"+
                                        ")) FROM Registrations r"+
                                        " JOIN Courses ON r.course = Courses.code LEFT JOIN WaitingList w ON w.student=r.student WHERE r.student = b.idnr), '[]'::jsonb), " +
                      "'seminarCourses', COALESCE(( " +
                              "SELECT s.seminarcount FROM seminarcourses s WHERE s.studentID = b.idnr), 0), " +
                      "'mathCredits', COALESCE(( " +
                              "SELECT p.mathCredits FROM PathToGraduation p WHERE p.student = b.idnr), 0), " +
                      "'totalCredits', COALESCE(( " +
                              "SELECT p.totalCredits FROM PathToGraduation p WHERE p.student = b.idnr), 0), " +
                      "'canGraduate', COALESCE(( " +
                              "SELECT p.qualified FROM PathToGraduation p WHERE p.student = b.idnr), false)" +
                      ") AS jsondata FROM BasicInformation b WHERE b.idnr = ?");
                      ){
            
            st.setString(1, student);
            
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