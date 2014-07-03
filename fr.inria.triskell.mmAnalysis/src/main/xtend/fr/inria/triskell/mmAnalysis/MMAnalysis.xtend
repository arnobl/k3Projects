package fr.inria.triskell.mmAnalysis

import fr.inria.diverse.k3.al.annotationprocessor.Aspect
import fr.inria.diverse.k3.al.annotationprocessor.OverrideAspectMethod
import java.io.IOException
import java.nio.charset.Charset
import java.nio.file.DirectoryStream
import java.nio.file.FileAlreadyExistsException
import java.nio.file.FileSystems
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
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
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl

import static extension fr.inria.triskell.mmAnalysis.EPackageAspect.*
import java.util.Map

class MMAnalysis{
	public def run() {
		//Load Ecore Model
		var fact = new EcoreResourceFactoryImpl
		if(!EPackage.Registry.INSTANCE.containsKey(EcorePackage.eNS_URI))
			EPackage.Registry.INSTANCE.put(EcorePackage.eNS_URI, EcorePackage.eINSTANCE)
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("ecore", fact)
		val ctx = new ContextAnalysis
//		val uri = URI.createURI("fsm.ecore")
//		val res = rs.getResource(uri, true);
//		res.contents.filter(typeof(EPackage)).forEach[count(ctx)]
//		ctx.incrNbMetamodel
//		res.unload
//		println(ctx)
		
//		val errFolder = "/home/ablouin/data/dev/metamodels/v2/metamodels/sample2-notloadable/"
//		val nonValidFolder = "/media/data/dev/metamodels/v2/metamodels/sample1-remaining/notValid"
		val DirectoryStream<Path> ds = Files.newDirectoryStream(FileSystems.getDefault().getPath("/home/ablouin/data/dev/metamodels/v2/metamodels/metamodels-sample1"))
		ds.forEach[file | analyseDir(ctx, file)	]
		ds.close
//		println(ctx)
		ctx.write
	}
	
	static val testStr = ".tests" // "tests" ".test" ".test" "test" ".test." ".tests"
	
	// latest, finitestate, 
	
		def void analyseDirTest(ContextAnalysis ctx, Path file, boolean mustMove) {
		if(mustMove || file.toString.split("/").last.toLowerCase.endsWith(testStr)) { // .endsWith(".test") .contains(testStr) .equals(testStr)
			// move
//			println(file.toString.split("/").last.toLowerCase)
			val str = file.parent.toString.replace("/metamodels-sample1/", "/sample4-test/")
			Files.createDirectories(FileSystems.getDefault.getPath(str))
			try{
				Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
			}catch(FileAlreadyExistsException e) {
				println(file)
//				if(Files.isDirectory(file)) {
//					val DirectoryStream<Path> ds = Files.newDirectoryStream(file)
//					ds.forEach[f | analyseDirTest(ctx, f, true)]
//					ds.close
//				}
			}
		}
		else {
			if(Files.isDirectory(file)) {
				val DirectoryStream<Path> ds = Files.newDirectoryStream(file)
				ds.forEach[f | analyseDirTest(ctx, f, false)]
				ds.close
			}
		}
	}
	
	def void analyseDir(ContextAnalysis ctx, Path file) {
		if(Files.isDirectory(file)) {
			val DirectoryStream<Path> ds = Files.newDirectoryStream(file)
			ds.forEach[f | analyseDir(ctx, f)]
			ds.close
		}else {
			try {
				val uri = URI.createURI(file.toString)
				val rs = new ResourceSetImpl()
				val res = rs.getResource(uri, true)
				ctx.nextMetamodel(file.fileName.toString)
				res.contents.filter(typeof(EPackage)).forEach[count(ctx)]
//				res.contents.filter(typeof(EPackage)).forEach[p | 
//					try {
//					Diagnostician.INSTANCE.validate(p)
//					}catch(Exception e) {
//						println("NOT VALID>>>> " +file.toString)
//						val str = file.parent.toString.replace("/metamodels-sample1/", "/sample3-notValid/")
//						Files.createDirectories(FileSystems.getDefault.getPath(str))
//						Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
////							ctx.incrNonValidMM
//					}
//				]
//					println("OK>>>"+file.fileName.toString)
					ctx.writeDataMM
				res.unload
//				ctx.checkEmpty
//				ctx.onEndMetamodel
			}catch(Exception e) {
				println("ERR>>>"+file.fileName.toString)
//				val str = file.parent.toString.replace("/metamodels-sample1/", "/sample5-redundant/")
//				println(str)
//				Files.createDirectories(FileSystems.getDefault.getPath(str))
//				Files.move(file, FileSystems.getDefault.getPath(str, file.fileName.toString))
	//			e.printStackTrace
			}
		}
	}


	def static void main(String[] args) {
		new MMAnalysis().run
	}
}


class ContextAnalysis {
	val Map<String,String> mms = newHashMap()
	protected var String currentMM
	protected var double nbClasses = 0
	protected var double nbPackages = 0
	protected var double nbDataTypes = 0
	protected var double nbAttr = 0
	protected var double nbMetamodels = 0
	protected var double nbReferences = 0
	protected var double nbOperations = 0
	protected var double nbAnnotations = 0
	protected var double nbFactories = 0
	protected var double nbEnums = 0
	protected var double nbEnumsLiteral = 0
	
	protected val StringBuilder dataClass = new StringBuilder
	protected val StringBuilder dataOp = new StringBuilder
	protected val StringBuilder dataMM = new StringBuilder
	
	private val t = '\t'
	private val eol = '\n'
	private val tru = '1'
	private val fal = '0'


	public def void nextMetamodel(String name) {
		currentMM = name
		nbClasses = 0
		nbPackages = 0
		nbDataTypes = 0
		nbReferences = 0
		nbAttr = 0
		nbOperations = 0
		nbEnums = 0
		nbEnumsLiteral = 0
		nbFactories = 0
	}
	
	
	public def void checkEmpty() {
		if(nbClasses==0 && nbDataTypes==0 && nbEnums==0)
			throw new IllegalArgumentException
	}
	
	public def void onEndMetamodel() {
		val String ident = nbClasses + " " + nbPackages + " " + nbDataTypes + " " + nbReferences + " " + nbAttr + " " + nbOperations + " " +
			nbEnums + " " + nbEnumsLiteral
		val otherName = mms.get(ident)
		if(otherName!=null && Utils::LevenshteinDistance(currentMM.toLowerCase, otherName.toLowerCase)<4) {
			throw new IllegalArgumentException
		}
		mms.put(ident, currentMM)
	}
	
	
	public def void writeDataClass(EClass clazz) {
		nbClasses = nbClasses + 1
		nbAttr = nbAttr + clazz.EAllAttributes.size
		nbReferences = nbReferences + clazz.EReferences.size
		
		dataClass.append(currentMM).append(t).append(clazz.name).append(t).append(
			if(clazz.abstract)tru else fal).append(t).append(clazz.EAllAttributes.size.toString).append(t).append(clazz.EAllOperations.size.toString).append(
			t).append(clazz.EAllReferences.size.toString).append(t).append(clazz.EAllSuperTypes.size.toString).append(eol)
	}
	
	public def void writeDataOperation(EOperation op) {
		nbOperations = nbOperations + 1
		
		dataOp.append(currentMM).append(t).append(op.EContainingClass.name).append(t).append(op.name).append(t).append(
			op.lowerBound).append(t).append(op.upperBound).append(t).append(if(op.EType==null) '0' else '1').append(
			t).append(op.EParameters.size).append(eol)
	}
	
	public def void writeDataMM() {
		nbMetamodels = nbMetamodels + 1
		
		dataMM.append(currentMM).append(t).append(nbPackages.intValue).append(t).append(nbClasses.intValue).append(t).append(nbDataTypes.intValue).append(t).
		append(nbReferences.intValue).append(t).append(nbAttr.intValue).append(t).append(nbOperations.intValue).append(t).append(nbEnums.intValue).append(t).
		append(nbEnumsLiteral.intValue).append(t).append(nbFactories.intValue).append(t).append(eol)
	}
	
	
	public def void write() {
		var Path newFile = Paths.get("./dataClass.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		var buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tClass name\tAbstract\tNb Attrs\tnb Ops\tnb Refs\tnbSupers")
		buffer.newLine
		buffer.append(dataClass)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
		
		newFile = Paths.get("./dataOp.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tClass name\tOp name\tLower bound\tUpper bound\tHas return\tnb param")
		buffer.newLine
		buffer.append(dataOp)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
		
		newFile = Paths.get("./dataMM.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tnb pkgs\tnb classes\tnb data types\tnb refs\tnb attrs\tnb ops\tnb enums\tnb enum literals\tnb factories")
		buffer.newLine
		buffer.append(dataMM)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
	}
	
	
//	public override String toString() {
//		return "\nnb nbMetamodels: " + nbMetamodels +
//		"\nnb classes per MM: " + nbClasses/nbMetamodels + 
//		"\nnb data types per MM: " + nbDataTypes/nbMetamodels + 
//		"\nnb nb enums per MM (contained in data types): " + nbEnums/nbMetamodels + 
//		"\nnb nb enums literal per enum: " + nbEnumsLiteral/nbEnums + 
//		"\nnb packages per MM: " + nbPackages/nbMetamodels + 
//		"\nnb attributes per class: " + nbAttr/nbClasses +
//		"\nnb classes per pkg: " + nbClasses/nbPackages +
//		"\nnb references per class: " + nbReferences/nbClasses +
//		"\nnb annotations per metamodel: " + nbAnnotations/nbMetamodels +
//		"\nnb factory per metamodel: " + nbFactories/nbMetamodels
//	}
}


@Aspect(className=typeof(EModelElement))
class EModelElementAspect {
	public def void count(ContextAnalysis ctx) {
		ctx.nbAnnotations = ctx.nbAnnotations + _self.EAnnotations.size
		_self.EAnnotations.forEach[count(ctx)]
	}
}


@Aspect(className=typeof(EClass))
class EClassAspect extends EModelElementAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		_self.EOperations.forEach[count(ctx)]
		ctx.writeDataClass(_self)
	}
}

@Aspect(className=typeof(EDataType))
class EDataTypeAspect extends EModelElementAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		ctx.nbDataTypes = ctx.nbDataTypes + 1
	}
}


@Aspect(className=typeof(EEnum))
class EEnumAspect extends EDataTypeAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		ctx.nbEnums = ctx.nbEnums + 1
		_self.ELiterals.forEach[count(ctx)]
	}
}


@Aspect(className=typeof(EEnumLiteral))
class EEnumLiteralAspect extends EModelElementAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		ctx.nbEnumsLiteral = ctx.nbEnumsLiteral + 1
	}
}


@Aspect(className=typeof(EOperation))
class EOperationAspect extends EModelElementAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		ctx.writeDataOperation(_self)
	}
}


@Aspect(className=typeof(EPackage))
class EPackageAspect extends EModelElementAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		ctx.nbPackages = ctx.nbPackages + 1
		_self.EClassifiers.forEach[count(ctx)]
		_self.ESubpackages.forEach[count(ctx)]
		_self.EFactoryInstance.count(ctx)
	}
}


@Aspect(className=typeof(EFactory))
class EFactoryAspect extends EModelElementAspect {
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		_self.super_count(ctx)
		ctx.nbFactories = ctx.nbFactories + 1
	}
}

