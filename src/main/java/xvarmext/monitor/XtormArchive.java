package xvarmext.monitor;

import java.util.HashMap;
import java.util.Map;

import com.speno.xmon.agent.IxMon;
import com.windfire.apis.asysConnectBase;
import com.windfire.apis.asysConnectData;
import com.windfire.apis.asys.asysUsrSql;
import com.windfire.apis.data.asysDataResult;

public class XtormArchive implements com.speno.xmon.agent.IxMon{
	
	private static Map<String, String[]> getArchiveInfos() {
		asysConnectBase con = null;

		StringBuffer query = new StringBuffer();
		query.append("select A.archiveId, sum(B.maxSpace), sum(B.spaceLeft) from asysArchiveVolume A, asysVolume B \n");
		query.append("where A.volumeId = B.volumeId                                                                \n");
		query.append("group by A.archiveId                                                                         \n");
		
		Map<String, String[]> result = new HashMap<String, String[]>();
		
		String ip = System.getProperty("MonIp");
		String port = System.getProperty("MonPort");
		int iPort = 2102;
		try {
			iPort = Integer.parseInt(port);
		} catch (Exception e) {}

		try {
			con = new asysConnectData(ip, iPort, "MONITOR", "SUPER", "SUPER");
			// Dynamic select
			asysUsrSql sql = new asysUsrSql(con);
			int ret = sql.retrieve("SIMPLESQL_MAIN", query.toString(), 1000);
			if (ret != 0)
				throw new Exception(sql.getLastError());

			asysDataResult res = sql.getResult();
			
			// Go through all rows
			while (res.nextRow()){
				String archiveId = res.getColValue(0);
				String maxSpace = res.getColValue(1);
				String spaceLeft = res.getColValue(2);
				long usedSpace = Long.parseLong(maxSpace) - Long.parseLong(spaceLeft);
				
				result.put(archiveId, new String[]{maxSpace, Long.toString(usedSpace)});
			}

			return result;

		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			if (con != null){
				con.close();
			}
		}

	}
	
	// override
	public long getValue(String resourceID, String propertyName) {
		Map<String,String[]> infos = getArchiveInfos();
		String[] data = infos.get(resourceID);
		if (data == null)
			return 0;
		
		if ("USE".equals(propertyName)) {
//			System.out.println("ARCHIVE " + resourceID + "USE : " + Long.parseLong(data[1]));
			return Long.parseLong(data[1])/1024;
		}
		else if ("TOTAL".equals(propertyName)) {
//			System.out.println("ARCHIVE " + resourceID + "TOTAL : " + Long.parseLong(data[0]));
			return Long.parseLong(data[0])/1024;
		}
		else
			return 0;

	}

//	@Override
	public HashMap<String, String> getExtMap() {
		// TODO Auto-generated method stub
		return null;
	}
		
}
