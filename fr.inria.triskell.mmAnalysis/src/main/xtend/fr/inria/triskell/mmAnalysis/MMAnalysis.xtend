package fr.inria.triskell.mmAnalysis

import fr.inria.triskell.k3.Aspect
import fr.inria.triskell.k3.OverrideAspectMethod
import java.io.IOException
import java.nio.charset.Charset
import java.nio.file.DirectoryStream
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
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl

import static extension fr.inria.triskell.mmAnalysis.EModelElementAspect.*

class MMAnalysis{
	public def run() {
		//Load Ecore Model
		var fact = new EcoreResourceFactoryImpl
		if(!EPackage.Registry.INSTANCE.containsKey(EcorePackage.eNS_URI))
			EPackage.Registry.INSTANCE.put(EcorePackage.eNS_URI, EcorePackage.eINSTANCE)
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("ecore", fact)
		val ctx = new ContextAnalysis
//		val rs = new ResourceSetImpl()
//		val uri = URI.createURI("fsm.ecore")
//		val res = rs.getResource(uri, true);
//		res.contents.filter(typeof(EPackage)).forEach[count(ctx)]
//		ctx.incrNbMetamodel
//		res.unload
//		println(ctx)
		
		val DirectoryStream<Path> ds = Files.newDirectoryStream(FileSystems.getDefault().getPath("/home/ablouin/data/dev/metamodels/metamodels"))
		
		ds.forEach[file |
			try{
				val rs = new ResourceSetImpl()
				val uri = URI.createURI(file.toString)
				val res = rs.getResource(uri, true);
				ctx.setCurrentMM(file.fileName.toString)
				res.contents.filter(typeof(EPackage)).forEach[count(ctx)]
				ctx.incrNbMetamodel
				res.unload
			}catch(Exception e) {
				println("ERR>>>>" + file.toString)
				e.printStackTrace
			}
		]
		ds.close	
		println(ctx)
		ctx.write
	}


	def static void main(String[] args) {
		new MMAnalysis().run()
	}
}


class ContextAnalysis {
	protected var String currentMM
	protected var double nbClasses = 0
	protected var double nbPackages = 0
	protected var double nbDataTypes = 0
	protected var double nbAttr = 0
	protected var double nbMetamodels = 0
	protected var double nbReferences = 0
	protected var double nbAnnotations = 0
	protected var double nbFactories = 0
	protected var double nbEnums = 0
	protected var double nbEnumsLiteral = 0
	
	protected var StringBuilder dataClass = new StringBuilder
	protected var StringBuilder dataMM = new StringBuilder
	
	private val t = '\t'
	private val eol = '\n'
	private val tru = '1'
	private val fal = '0'

	
	
	public def void writeDataClass(EClass clazz) {
		nbClasses = nbClasses + 1
		nbAttr = nbAttr + clazz.EAllAttributes.size
		nbReferences = nbReferences + clazz.EReferences.size
		
		dataClass.append(currentMM).append(t).append(clazz.name).append(t).append(
			if(clazz.abstract)tru else fal).append(t).append(clazz.EAllAttributes.size.toString).append(t).append(clazz.EAllOperations.size.toString).append(
			t).append(clazz.EAllReferences.size.toString).append(t).append(clazz.EAllSuperTypes.size.toString).append(eol)
	}
	
	
	public def void write() {
		var Path newFile = Paths.get("./dataClass.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		val buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tClass name\tAbstract\tNb Attrs\tnb Ops\tnb Refs\tnbSupers")
		buffer.newLine
		buffer.append(dataClass)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
	}
	
	
	public def void incrNbMetamodel() { nbMetamodels = nbMetamodels + 1 }
	public def void setCurrentMM(String mm) { currentMM = mm }
	
	public override String toString() {
		return "\nnb nbMetamodels: " + nbMetamodels +
		"\nnb classes per MM: " + nbClasses/nbMetamodels + 
		"\nnb data types per MM: " + nbDataTypes/nbMetamodels + 
		"\nnb nb enums per MM (contained in data types): " + nbEnums/nbMetamodels + 
		"\nnb nb enums literal per enum: " + nbEnumsLiteral/nbEnums + 
		"\nnb packages per MM: " + nbPackages/nbMetamodels + 
		"\nnb attributes per class: " + nbAttr/nbClasses +
		"\nnb classes per pkg: " + nbClasses/nbPackages +
		"\nnb references per class: " + nbReferences/nbClasses +
		"\nnb annotations per metamodel: " + nbAnnotations/nbMetamodels +
		"\nnb factory per metamodel: " + nbFactories/nbMetamodels
	}
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

