package fr.inria.triskell.mmAnalysis

import fr.inria.triskell.k3.Aspect
import fr.inria.triskell.k3.OverrideAspectMethod
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
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
		
		var rs = new ResourceSetImpl()
		var uri = URI.createURI("fsm.ecore")
		val res = rs.getResource(uri, true);
		val ctx = new ContextAnalysis
		res.contents.filter(typeof(EModelElement)).forEach[pkg | pkg.count(ctx)]
		res.unload
		println(ctx)
	}


	def static void main(String[] args) {
		new MMAnalysis().run()
	}
}


class ContextAnalysis {
	protected var int nbClasses = 0
	protected var int nbPackages = 0
	
	public override String toString() {
		return "nb classes: " + nbClasses + "; nb packages: " + nbPackages
	}
}


@Aspect(className=typeof(EModelElement))
class EModelElementAspect {
	public def void count(ContextAnalysis ctx) {println("AIE")}
}


@Aspect(className=typeof(EClass))
class EClassAspect extends EModelElementAspect {
	public static var int j = 0
	
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		println(self.name)
		ctx.nbClasses = ctx.nbClasses + 1
	}
}


@Aspect(className=typeof(EPackage))
class EPackageAspect extends EModelElementAspect {
	
	@OverrideAspectMethod
	public def void count(ContextAnalysis ctx) {
		ctx.nbPackages = ctx.nbPackages + 1
		self.EClassifiers.forEach[cl | cl.count(ctx)]
		self.ESubpackages.forEach[sub | sub.count(ctx)]
	}
}


