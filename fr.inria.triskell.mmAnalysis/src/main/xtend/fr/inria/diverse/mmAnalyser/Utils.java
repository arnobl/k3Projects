package fr.inria.diverse.mmAnalyser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class Utils {
	public static List<String> readWebPage(String url) {
		List<String> list = new ArrayList<>();
		boolean ok = false;
		
		while(!ok) {
			try{
				URL oracle = new URL(url);
				try(InputStream is = oracle.openStream()){
					try(BufferedReader in = new BufferedReader(new InputStreamReader(is))){
						String inputLine;
						while ((inputLine = in.readLine()) != null) {
							list.add(inputLine);
						}
						ok = true;
					}
				}catch(IOException ex) {
					if(ex.getMessage().contains("HTTP response code")) {
						System.out.println("WAITING FOR GITHUB ACCESS");
						try {
							Thread.sleep(55000);
						} catch (InterruptedException e) {
							System.out.println("cannot sleep");
							ok = true;
							e.printStackTrace();
						}
					}
				}
			}catch(IOException ex) {
				ex.printStackTrace();
				ok = true;
			}
		}
		return list;
	}
	
	
	public static int LevenshteinDistance(String s0, String s1) {
		int len0 = s0.length()+1;
		int len1 = s1.length()+1;
	 
		// the array of distances
		int[] cost = new int[len0];
		int[] newcost = new int[len0];
	 
		// initial cost of skipping prefix in String s0
		for(int i=0;i<len0;i++) cost[i]=i;
	 
		// dynamicaly computing the array of distances
	 
		// transformation cost for each letter in s1
		for(int j=1;j<len1;j++) {
	 
			// initial cost of skipping prefix in String s1
			newcost[0]=j-1;
	 
			// transformation cost for each letter in s0
			for(int i=1;i<len0;i++) {
	 
				// matching current letters in both strings
				int match = (s0.charAt(i-1)==s1.charAt(j-1))?0:1;
	 
				// computing cost for each transformation
				int cost_replace = cost[i-1]+match;
				int cost_insert  = cost[i]+1;
				int cost_delete  = newcost[i-1]+1;
	 
				// keep minimum cost
				newcost[i] = Math.min(Math.min(cost_insert, cost_delete),cost_replace );
			}
	 
			// swap cost/newcost arrays
			int[] swap=cost; cost=newcost; newcost=swap;
		}
	 
		// the distance is the cost for transforming all letters in both strings
		return cost[len0-1];
	}
}
