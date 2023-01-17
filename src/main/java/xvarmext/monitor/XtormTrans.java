package xvarmext.monitor;

import java.util.HashMap;

import com.speno.xmon.agent.IxMon;
import com.windfire.apis.asysConnectBase;
import com.windfire.apis.asysConnectData;
import com.windfire.apis.oper.asysOperActivity;
import com.windfire.apis.oper.asysOperMisc;
import com.windfire.base.asysParmList;
import com.windfire.base.asysTransact;

public class XtormTrans implements com.speno.xmon.agent.IxMon{
	
	private static int getTransCount() {
		asysConnectBase con = null;
		
		String ip = System.getProperty("MonIp");
		String port = System.getProperty("MonPort");
		int iPort = 2102;
		try {
			iPort = Integer.parseInt(port);
		} catch (Exception e) {}

		try {
			con = new asysConnectData(ip, iPort, "MONITOR", "SUPER", "SUPER");
			
	   		asysOperMisc asysOM = new asysOperMisc(con, false);
	       	int ret = asysOM.retrieveTransCount();
	       	if(ret == 0){
	       	    return asysOM.getTransCount();
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
			int count = getTransCount();
			
			if ("USE".equals(propertyName)) {
				System.out.println("CONN " + resourceID + "USE : " + count);
				return count;
			}
			else
				return -1;

		}
		
	
	public static void main(String[] args) {
		System.out.println(XtormTrans.getTransCount());
	}

//	@Override
	public HashMap<String, String> getExtMap() {
		// TODO Auto-generated method stub
		return null;
	}
}
