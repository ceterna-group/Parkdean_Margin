/**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Test class for RMReportClass
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
@IsTest
public class RMReportClassTest {
    
  @IsTest
  public static void testGetReportData() {
    String data = RMReportClass.getReportData();
    System.assertNotEquals(null, data);
  }

}