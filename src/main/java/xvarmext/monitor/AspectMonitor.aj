package xvarmext.monitor;


import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

import com.speno.xmon.agent.MainXAgent;
import com.windfire.base.asysCmnd;
import com.windfire.base.asysTransact;

@Aspect
public class AspectMonitor {
	
	private static MainXAgent agent = new MainXAgent();

	private String logId = "XtormAgent";
	
	// init
	@Pointcut("execution(* com.windfire.comm.asysSockSrvr.initialize(..))")
	public void init() {
	}
	@Around("AspectMonitor.init()")
	public Object init(ProceedingJoinPoint joinPoint) throws Throwable {
		
		Object retVal = joinPoint.proceed();
		
		String property = System.getProperty("MonLogId");
		if (property != null && property.length() > 0)
			logId = property;
		
		// monitoring init
		agent.init(null);
		System.out.println("XMonitor aspect has been initialized.");
		agent.putEvent("[INFO]", "Server has been started", 1, System.currentTimeMillis(), "0", "", null);
		
		return retVal;
	}

	// term
	@Pointcut("execution(* com.windfire.comm.asysSockSrvr.terminate(..))")
	public void terminate() {
	}
	@Around("AspectMonitor.terminate()")
	public Object terminate(ProceedingJoinPoint joinPoint) throws Throwable {
		agent.putEvent("[INFO]", "Server has been shutdowned.", 1, System.currentTimeMillis(), "0", "", null);
		agent.shutdown();
		Object retVal = joinPoint.proceed();
		return retVal;
	}

	// transaction start!
	@Pointcut("execution(* com.windfire.base.asysTransact.start(..))")
	public void transactionStart() {}
	@Around("AspectMonitor.transactionStart()")
	public Object transactionStart(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = null;
		
		try {
			asysTransact t = (asysTransact)joinPoint.getTarget();
			retVal = joinPoint.proceed();
//			System.out.println("[START]" + t.toString());
			
			if (t.m_parm != null) {
				// create
				if (t.m_parm.m_subCmd == asysCmnd.DATA_ADDELEMENT) {
					agent.putInit("Register", t.transactionId, System.currentTimeMillis(), "0", "", null);
				}
				// download
				else if (t.m_parm.m_subCmd == asysCmnd.DATA_GETCONTENT) {
					agent.putInit("Inquiry", t.transactionId, System.currentTimeMillis(), "0", "", null);
				}
				// delete
				else if (t.m_parm.m_subCmd == asysCmnd.DATA_DELELEMENT) {
					agent.putInit("Delete", t.transactionId, System.currentTimeMillis(), "0", "", null);
				}
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			// TODO: put request
		}
		return retVal;
	}

	// transaction end!
	@Pointcut("execution(* com.windfire.base.asysTransact.end(..))")
	public void transactionEnd() {}
	@Around("AspectMonitor.transactionEnd()")
	public Object transactionEnd(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = null;

		try {
			asysTransact t = (asysTransact)joinPoint.getTarget();
			retVal = joinPoint.proceed();
//			System.out.println("[END]" + t.toString());

			Object[] args = joinPoint.getArgs();
			String errorMessage = (String)args[1];

			boolean result = (Boolean)retVal;
			if (!result) {
				agent.putCompError("", t.transactionId, System.currentTimeMillis(), "1", errorMessage, null);
			}
			else {
				if (t.m_rCode != 0)
					agent.putCompError("", t.transactionId, System.currentTimeMillis(), ""+t.m_rCode, t.m_errMsg, null);
				else {
					if (t.m_parm != null
							&& (t.m_parm.m_subCmd == asysCmnd.DATA_ADDELEMENT
								|| t.m_parm.m_subCmd == asysCmnd.DATA_GETCONTENT
								|| t.m_parm.m_subCmd == asysCmnd.DATA_DELELEMENT) ) {
						agent.putCompSuccess("", t.transactionId, System.currentTimeMillis(), "0", "", null);
					}
				}
			}
			
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			// TODO: put request
		}
		return retVal;
	}
	
	
	// logging
	@Pointcut("execution(* com.windfire.agents.asysLogWriterLog4j.logMessage(..))")
	public void log4j() {}
	@Around("AspectMonitor.log4j()")
	public Object log4j(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = null;

		try {
			retVal = joinPoint.proceed();

			Object[] args = joinPoint.getArgs();
			String src = (String)args[0];
			Integer severity = (Integer)args[1];
			Integer msgId = (Integer)args[2];
			String defMsg = (String)args[3];
			String ins1 = (String)args[4];
			String ins2 = (String)args[5];

			StringBuffer sb = new StringBuffer();
	    	
	    	if(ins1 == null) ins1 = "";
	    	if(ins2 == null) ins2 = "";
	    	defMsg = defMsg.replaceFirst("%1", ins1);
	    	defMsg = defMsg.replaceFirst("%2", ins2);

	    	sb.append(defMsg);
			
	    	agent.putLog(logId, sb.toString(), System.currentTimeMillis(), "", "0", null);
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			// TODO: put request
		}
		return retVal;
	}
	
	// logging
	@Pointcut("execution(* com.windfire.agents.asysLogWriterFile.logMessage(..))")
	public void log() {}
	@Around("AspectMonitor.log()")
	public Object log(ProceedingJoinPoint joinPoint) throws Throwable {
		Object retVal = null;

		try {
			retVal = joinPoint.proceed();

			Object[] args = joinPoint.getArgs();
			String src = (String)args[0];
			Integer severity = (Integer)args[1];
			Integer msgId = (Integer)args[2];
			String defMsg = (String)args[3];
			String ins1 = (String)args[4];
			String ins2 = (String)args[5];

			StringBuffer sb = new StringBuffer();
	    	
	    	if(ins1 == null) ins1 = "";
	    	if(ins2 == null) ins2 = "";
	    	defMsg = defMsg.replaceFirst("%1", ins1);
	    	defMsg = defMsg.replaceFirst("%2", ins2);

	    	sb.append(defMsg);
			
	    	agent.putLog(logId, sb.toString(), System.currentTimeMillis(), "", "0", null);
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			// TODO: put request
		}
		return retVal;
	}

}