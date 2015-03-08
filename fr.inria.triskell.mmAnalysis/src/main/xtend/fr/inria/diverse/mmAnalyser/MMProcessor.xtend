package fr.inria.diverse.mmAnalyser

import java.io.File
import java.io.FileInputStream
import java.nio.file.DirectoryNotEmptyException
import java.nio.file.FileSystems
import java.nio.file.Files
import java.nio.file.Path
import java.util.Set
import org.apache.commons.codec.digest.DigestUtils
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EModelElement
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl

class MMProcessor {
	def static void main(String[] args) {
		new MMProcessor("/media/data/dev/testMM/metamodels", "/media/data/dev/testMM/", 5, true).run
	}
	
	public static val String ecoreExt = '.ecore'
	val String targetFolder
	val String sourceFolder
	val Path targetPath
	val Path sourcePath
	val int pass
	val boolean clean
	val debug = false
	
	new(String sourceFolder, String targetFolder, int pass, boolean clean) {
		this.targetFolder = targetFolder
		this.sourceFolder = sourceFolder
		this.pass = pass
		this.clean = clean
		
		// 	Creating the target folder
		targetPath = FileSystems.getDefault.getPath(targetFolder)
		if(!Files::exists(targetPath))
			Files::createDirectory(targetPath)
			
		sourcePath = FileSystems.getDefault.getPath(sourceFolder)
		if(!Files::exists(sourcePath))
			throw new IllegalArgumentException("Invalid source folder")
			
		if(pass<1 || pass>6)
			throw new IllegalArgumentException("Invalid pass number. Must be between 1 and 5 included")
	}
	
	public def run() {
		// Registering the ecore namespace
		if(!EPackage.Registry.INSTANCE.containsKey(EcorePackage.eNS_URI))
			EPackage.Registry.INSTANCE.put(EcorePackage.eNS_URI, EcorePackage.eINSTANCE)
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap.put("ecore", new EcoreResourceFactoryImpl)
		
//		// Registering the UML namespace
//		if(!EPackage.Registry.INSTANCE.containsKey(UmlPackage.eNS_URI))
//			EPackage.Registry.INSTANCE.put(UmlPackage.eNS_URI, UmlPackage.eINSTANCE)
//		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap.put("uml", new XMIResourceFactoryImpl)
		
		// Opening the source folder
		val ctx = new ContextAnalyser
		val ds = Files.newDirectoryStream(FileSystems.getDefault.getPath(sourceFolder))
		ds.forEach[analyseDir(ctx)]
		ds.close
		if(clean)
			removeEmptyFolders(sourcePath)
		if(pass==6)
			ctx.write
	}
	
	
	private def void analyseDir(Path file, ContextAnalyser ctx) {
		if(Files.isDirectory(file)) {
			val ds = Files.newDirectoryStream(file)
			ds.forEach[analyseDir(ctx)]
			ds.close
		}else {
			val rs  = new ResourceSetImpl()
			try {
				if(debug) println("loading: " + file)
				val uri = URI.createURI(file.toString)
				val res = rs.getResource(uri, true)
				ctx.nextMetamodel(file.fileName.toString)
				if(pass!=1) {
					analyseMetamodel(res.contents.filter(typeof(EPackage)), ctx, file)
				}
				
				// UML
//				val str = targetFolder+File::separator+"notClass"+file.toString.replace(sourceFolder, "")
//				
//				if(!res.allContents.exists[elt | elt instanceof uml.Class]) {
//					Files.createDirectories(FileSystems.getDefault.getPath(str))
//					Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
//				}
//				
//				if(res.contents.head==null){
//					Files.createDirectories(FileSystems.getDefault.getPath(str))
//					Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
//					println("empty!!")
//				}
			}catch(Exception ex) {
				if(pass==1) {
					passNotLoadable(file, sourceFolder, targetFolder)
				}else
					ex.printStackTrace
			}
			for(var i = rs.getResources.iterator; i.hasNext;) {
				i.next.unload
				i.remove
			}
		}
	}
	
	
	private def void analyseMetamodel(Iterable<EPackage> mm, ContextAnalyser ctx, Path file) {
		switch pass {
			case 2: passNotValid(mm, file)
			case 3: passTest(file)
			case 4: passEmptyToy(mm, ctx, file)
			case 5: passDuplicatedCheckSum(mm, ctx, file)
			case 6: passAnalyseMM(mm, ctx, true)
		}
	}
	
	
	private def void countModelElement(EModelElement elt, ContextAnalyser ctx) {
		ctx.nbAnnotations = ctx.nbAnnotations + elt.EAnnotations.size
		elt.EAnnotations.forEach[countModelElement(ctx)]
	}
	
	
	private def void countPackage(EPackage pkg, ContextAnalyser ctx) {
		countModelElement(pkg, ctx)
		ctx.nbPackages++
		pkg.EClassifiers.forEach[countClassifier(ctx)]
		pkg.ESubpackages.forEach[countPackage(ctx)]
		pkg.EFactoryInstance.countFactory(ctx)
	}

	private def void countClassifier(EClassifier cl, ContextAnalyser ctx) {
		switch cl {
			EClass : countClass(cl, ctx)
			EEnum : countEnum(cl, ctx)
			EDataType : countDataType(cl, ctx)
			default : println("ERROR, eclassifier not supported: " + cl)
		}
	}	
	
	private def void countClass(EClass cl, ContextAnalyser ctx) {
		countModelElement(cl, ctx)
		cl.EOperations.forEach[countOperation(ctx)]
		ctx.writeDataClass(cl)
	}

	private def void countFactory(EFactory fa, ContextAnalyser ctx) {
		countModelElement(fa, ctx)
		ctx.nbFactories++
	}
	
	private def void countDataType(EDataType dt, ContextAnalyser ctx) {
		countModelElement(dt, ctx)
		ctx.nbDataTypes++
	}
	
	private def void countEnum(EEnum en, ContextAnalyser ctx) {
		countDataType(en, ctx)
		ctx.nbEnums++
		en.ELiterals.forEach[countEnumLit(ctx)]
	}
	
	private def void countEnumLit(EEnumLiteral en, ContextAnalyser ctx) {
		countModelElement(en, ctx)
		ctx.nbEnumsLiteral++
	}
	
	
	private def void countOperation(EOperation op, ContextAnalyser ctx) {
		countModelElement(op, ctx)
		ctx.writeDataOperation(op)
	}


	
	private def void passAnalyseMM(Iterable<EPackage> mm, ContextAnalyser ctx, boolean writeData) {
		mm.forEach[countPackage(ctx)]
		if(writeData) ctx.writeDataMM
	}
	
		
	public static def void passNotLoadable(Path file, String sourceFolder, String targetFolder) {
		val str = targetFolder+File::separatorChar+file.toString.split("\\.").last+"sample2-notLoadable"+file.toString.replace(sourceFolder, "")
		println("NOT LOADABLE: " + file + " move to: " + str)
//		Files.createDirectories(FileSystems.getDefault.getPath(str))
//		Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
	}
	
	
	private def void passNotValid(Iterable<EPackage> mm, Path file) {
		mm.forEach[p | 
			try {
				Diagnostician.INSTANCE.validate(p)
			}catch(Exception e) {
				println("NOT VALID: " +file)
				val str = targetFolder+File::separator+"sample3-notValid"+file.toString.replace(sourceFolder, "")
				Files.createDirectories(FileSystems.getDefault.getPath(str))
				Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
			}
		]
	}
	
	
	val toyNames = #['dummy', 'foo']
	private def void passEmptyToy(Iterable<EPackage> mm, ContextAnalyser ctx, Path file) {
		passAnalyseMM(mm, ctx, false)
		var moved = false
		if(ctx.nbClasses==0 && ctx.nbEnums==0 && ctx.nbDataTypes==0) {
			println("EMPTY: " +file)
			val str = targetFolder+File::separator+"sample5-emptyToy"+file.toString.replace(sourceFolder, "")
			Files.createDirectories(FileSystems.getDefault.getPath(str))
			Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
			moved = true
		}
		else
		if(ctx.nbClasses==1) {
			val cl = mm.map[eAllContents.filter(EClassifier).toList].flatten.head
			if(toyNames.exists[str | cl.name.equalsIgnoreCase(str)]) {
				println("EMPTY foo: " + file)
				val str = targetFolder+File::separator+"sample5-emptyToy"+file.toString.replace(sourceFolder, "")
				Files.createDirectories(FileSystems.getDefault.getPath(str))
				Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
				moved = true
			}
		}
		if(!moved && ctx.nbAttr+ctx.nbOperations+ctx.nbReferences+ctx.nbDataTypes+ctx.nbEnums+ctx.nbGenerics==0 && ctx.nbClasses<3) {
			println("EMPTY2: " + file)
			val str = targetFolder+File::separator+"sample5-emptyToy"+file.toString.replace(sourceFolder, "")
			Files.createDirectories(FileSystems.getDefault.getPath(str))
			Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
		}
	}
	
	private def void passTest(Path file) {
		val name = file.toString.replace(sourceFolder, "").toLowerCase
		if(name.contains("test") && !name.contains("latest") && !name.contains("finitestate") && !name.contains("contest") && 
			!name.contains("testability") && !name.contains("attest") && !name.contains("testing") && !name.contains("fatest") &&
			!name.contains("fittest")) {
				println("TEST: " +file)
				val str = targetFolder+File::separator+"sample4-test"+file.toString.replace(sourceFolder, "")
				Files.createDirectories(FileSystems.getDefault.getPath(str))
				Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
		}
	}
	
	
	val Set<String> checksums = newHashSet
		
	private def void passDuplicatedCheckSum(Iterable<EPackage> mm, ContextAnalyser ctx, Path file) {
		try{
			val fis = new FileInputStream(file.toFile)
			val md5 = DigestUtils::md5Hex(fis)
			if(checksums.contains(md5)) {
				println("DUPLICATE: " + md5 +" "   +file)
				val str = targetFolder+File::separator+"sample6-duplicated"+file.toString.replace(sourceFolder, "")
				Files::createDirectories(FileSystems::getDefault.getPath(str))
				Files::move(file, FileSystems::getDefault.getPath(str, file.fileName.toString))
			}
			else checksums.add(md5)
			fis.close
		}catch(Exception ex){}
	}
	
	
//	private def void passDuplicated(Iterable<EPackage> mm, ContextAnalyser ctx, Path file) {
//		passAnalyseMM(mm, ctx, false)
//		try {
//			ctx.onEndMetamodelCheckDuplicate
//		}catch(IllegalArgumentException ex) {
//			println("DUPLICATE: " +file)
//			val str = targetFolder+File::separator+"sample6-duplicated"+file.toString.replace(sourceFolder, "")
//			Files.createDirectories(FileSystems.getDefault.getPath(str))
//			Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
//		}
//	}
	
	
	private def void removeEmptyFolders(Path path) {
		val ds = Files.newDirectoryStream(FileSystems.getDefault.getPath(sourceFolder))
		ds.forEach[f|_removeEmptyFolders(f)]
		ds.close
    }
    
    
	private def void _removeEmptyFolders(Path path) {
	    if(path == null || path.endsWith(sourceFolder)) return;
		
	    if(Files.isDirectory(path)) {
			val ds = Files.newDirectoryStream(path)
			ds.forEach[f | _removeEmptyFolders(f)]
			ds.close
	        try {
	            Files.delete(path);
	        } catch(DirectoryNotEmptyException e) {
	            return;
	        }
	    }
    }
}