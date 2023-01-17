package xvarmext.monitor;

import java.util.HashMap;

import com.speno.xmon.agent.IxMon;
import com.windfire.apis.asysConnectBase;
import com.windfire.apis.asysConnectData;
import com.windfire.apis.oper.asysOperActivity;
import com.windfire.base.asysParmList;
import com.windfire.base.asysParmVector;
import com.windfire.base.asysTransact;

public class XtormDBConn implements com.speno.xmon.agent.IxMon{
	
	private static int[] getDBConnectionCount(String resourceID) {
		asysConnectBase con = null;
		
		int[] result = {-1, -1};
		
		String ip = System.getProperty("MonIp");
		String port = System.getProperty("MonPort");
		int iPort = 2102;
		try {
			if (ip == null || ip.length() < 1)
				ip = "localhost";
			iPort = Integer.parseInt(port);
		} catch (Exception e) {}

		try {
			con = new asysConnectData(ip, iPort, "MONITOR", "SUPER", "SUPER");
			
			asysOperActivity oa = new asysOperActivity(con, false);
			int rCode = oa.retrieve("DATA", "constatus", "");

			if (rCode == asysTransact.RCODE_OK) {
				int processing = 0;
				asysParmList l = (asysParmList)oa.m_data; 
				for (int i = 0; i < l.count(); i++){
					asysParmVector r = (asysParmVector) l.get(i); 
					
					if (resourceID.equals(r.get(0))) {
						if ("Processing".equals(r.get(1)))
								processing ++;
					}
				}
				
				result[0] = processing;
				result[1] = l.count();
				return result;
			}
			
			return result;

		} catch (Exception e) {
			e.printStackTrace();
			return new int[]{-1,-1};
		} finally {
			if (con != null){
				con.close();
			}
		}

	}
	
		public long getValue(String resourceID, String propertyName) {
			int[] count = XtormDBConn.getDBConnectionCount(resourceID);
			
			if ("USE".equals(propertyName)) {
				System.out.println("DBCONN " + resourceID + "USE : " + count[0]);
				return count[0];
			}
			if ("TOTAL".equals(propertyName)) {
				System.out.println("DBCONN " + resourceID + "TOTAL : " + count[1]);
				return count[1];
			}
			else
				return -1;

		}
		
	
	public static void main(String[] args) {
		int[] count = XtormDBConn.getDBConnectionCount("master");
		System.out.println(count[0]);
		System.out.println(count[1]);
	}

//	@Override
	public HashMap<String, String> getExtMap() {
		// TODO Auto-generated method stub
		return null;
	}
}
