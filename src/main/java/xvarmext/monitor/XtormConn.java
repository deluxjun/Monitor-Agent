package xvarmext.monitor;

import java.util.HashMap;

import com.speno.xmon.agent.IxMon;
import com.windfire.apis.asysConnectBase;
import com.windfire.apis.asysConnectData;
import com.windfire.apis.oper.asysOperActivity;
import com.windfire.base.asysParmList;
import com.windfire.base.asysTransact;

public class XtormConn implements com.speno.xmon.agent.IxMon{
	
	private static int getConnectionCount() {
		asysConnectBase con = null;
		
		String ip = System.getProperty("MonIp");
		String port = System.getProperty("MonPort");
		int iPort = 2102;
		try {
			iPort = Integer.parseInt(port);
		} catch (Exception e) {}

		try {
			con = new asysConnectData(ip, iPort, "MONITOR", "SUPER", "SUPER");
			
			asysOperActivity transCon = new asysOperActivity(con, true);
			int rCode = transCon.retrieve("COMM", "transact", "");
			if (rCode == asysTransact.RCODE_OK) {
				asysParmList tcons = (asysParmList)transCon.m_data;
				return tcons.count();
			}
			
			return -1;

		} catch (Exception e) {
			e.printStackTrace();
			return -1;
		} finally {
			if (con != null){
				con.close();
			}
		}

	}
	
		public long getValue(String resourceID, String propertyName) {
			int count = getConnectionCount();
			
			if ("USE".equals(propertyName)) {
				System.out.println("CONN " + resourceID + "USE : " + count);
				return count;
			}
			else
				return -1;

		}
		
	
	public static void main(String[] args) {
		System.out.println(XtormConn.getConnectionCount());
	}

//	@Override
	public HashMap<String, String> getExtMap() {
		// TODO Auto-generated method stub
		return null;
	}
}
