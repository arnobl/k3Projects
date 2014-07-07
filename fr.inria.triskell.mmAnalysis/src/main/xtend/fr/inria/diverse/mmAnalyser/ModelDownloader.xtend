package fr.inria.diverse.mmAnalyser

import java.io.FileOutputStream
import java.io.IOException
import java.net.MalformedURLException
import java.net.URL
import java.nio.channels.Channels
import java.nio.file.Files
import java.nio.file.Paths
import java.util.List

class ModelDownloader {
	def static void main(String[] args) {
		new ModelDownloader('uml', "/media/data/dev/testMM2/")
	}
	
	val String targetFolder
	val String extens
	val static url1 = 'https://github.com/search?type=Code&ref=searchresults&q=xmi+extension%3A'
	val static nbRes = 'code results'
	val static maxRes = 1000
	val int nbTotalRes
	var cpt = 0
		
	new(String ext, String targetFolder) {
		this.targetFolder = targetFolder
		this.extens = ext
		var maxSize = 1000
		var minSize = 0
		var url = url1+extens
		var page = Utils::readWebPage(url)
		nbTotalRes = getNbResults(page)
		var subsetNsRes = nbTotalRes

		while(cpt<nbTotalRes && subsetNsRes>0) {
			while(subsetNsRes>maxRes) {
				url = url1+extens+"+size:"+minSize+".."+maxSize
				page = Utils::readWebPage(url)
				subsetNsRes = getNbResults(page)
				if(subsetNsRes>maxRes) maxSize /=2
			}
			
			if(nbRes==-1) {
				println("ERROR " + url + "\n" + page.join("\n"))
			}
			else {
				val int nbPages = getNbPages(subsetNsRes)
				println(">>>" + maxSize + " " + subsetNsRes + " " + nbPages + " " + url)
				downloadPages(nbPages, url)
			}
			
			minSize = maxSize+1
			maxSize *= 10
			subsetNsRes = Integer.MAX_VALUE
		}
	}
	
	
	val static headerURLGithub = 'https://github.com'
	val static blob = "/blob/"
	val static raw = "/raw/"
	val static page = "&p="
	
	private def void downloadPages(int nbPages, String url) {
		val urlPage = url+page
		val extPattern = "."+extens+'"'
		val splitPattern = '"'

		for(var i=1; i<=nbPages; i++) {
			var page = Utils::readWebPage(urlPage+i)
			page = page.filter[contains(extPattern) && contains(blob)].map[split(splitPattern).get(1).replaceAll(blob, raw)].toList
			page.forEach[downloadFile]
			println(cpt+ "/" + nbTotalRes+ " -- " + url+"&page="+i)
		}
	}
	
	
	private def void downloadFile(String file) {
		val urlDownload = headerURLGithub+file
		val target = targetFolder + extens + "Models" + file.replaceFirst("/raw/[\\d\\w]+/", "/")
		var ok = false
		println("URL: " + urlDownload)
		cpt++
		
		val path = Paths.get(target)
		if(Files::exists(path)) return;
		Files.createDirectories(path.parent)

		try {
			val url = new URL(urlDownload)
			while(!ok) {
				try{
					val is = url.openStream
					val rbc = Channels.newChannel(is)
					val fos = new FileOutputStream(target)
					fos.getChannel.transferFrom(rbc, 0, Long.MAX_VALUE)
					fos.close
					rbc.close
					is.close
					ok = true
				}catch(IOException ex) {
					if(ex.getMessage().contains("HTTP response code")) {
						System.out.println("WAITING FOR GITHUB ACCESS");
						try {Thread.sleep(55000);}
						catch(InterruptedException e) {
							System.out.println("cannot sleep");
							e.printStackTrace();
							ok = true
						}
					}else {
						ex.printStackTrace
						ok = true
					}
				}
			}
		}catch(MalformedURLException ex){ex.printStackTrace}
	}
	

	private def int getNbPages(int nbResults) {
		return Math::ceil(nbResults/10.0).intValue
	}
	
	private def int getNbResults(List<String> page) {
		val res = page.findFirst[contains(nbRes)]
		if(res==null || res.empty) return -1
		val num = res.split(' ').findFirst[str | !str.empty && Character.isDigit(str.charAt(0))]
		try { return Integer.parseInt(num.replaceAll(",", "")) }
		catch(NumberFormatException ex) { return -1 }
	}
}