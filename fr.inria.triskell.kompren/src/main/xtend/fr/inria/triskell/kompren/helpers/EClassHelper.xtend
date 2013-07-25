/*
 * Creation : November 22, 2010
 * Licence  : EPL
 * Copyright: INRIA Rennes, Triskell
 * Authors  : Arnaud Blouin
 */
package fr.inria.triskell.kompren.helpers

import org.eclipse.emf.ecore.ENamedElement
import fr.inria.triskell.k3.Aspect
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EClass
import java.util.List
import org.eclipse.emf.ecore.EReference
import java.util.ArrayList



@Aspect(className=typeof(ENamedElement)) class ENamedElementAspectQName {
	public def String getQualifiedName(String sep) {
		var result = self.name
		
		if(self.eContainer!=null && self.eContainer instanceof ENamedElement)
			result = (self.eContainer as ENamedElement).getQualifiedName(sep) + sep + self.name 
		
		return result
	}
	
	public def String getQualifiedName(){
		return self.getQualifiedName("::")
	}
}


@Aspect(className=typeof(EClassifier)) class EClassifierAspectQName extends ENamedElementAspectQName {
	/**
	 * @param clazz The class to test.
	 * @return True: If the calling class is a super type of the given class.
	*/
	public def boolean isSuperTypeOfBis(EClass clazz) {
		var result = clazz!=null
		val qualifiedName = self.getQualifiedName
		val List<EClass> superTypes = clazz.getESuperTypes//workaround k3
		
		
		if(result){//FIXME xtend
			result = superTypes.exists[st | st.getQualifiedName.equals(qualifiedName) ]

			if(!result)
				result = superTypes.exists[st | self.isSuperTypeOfBis(st)]
		}
		
		return result
	}
}


@Aspect(className=typeof(EClass)) class EClassAspectQName extends EClassifierAspectQName {
	public def List<EClass> getConcreteSubClasses(List<EClass> allClasses) {
		val List<EClass> classes = allClasses//workaround k3
		return classes.filter[c | !c.isAbstract && self.isSuperTypeOfBis(self, c)].toList
	}


	public def boolean canBeRootClass(List<EClass> allClasses) {
		val List<EClass> classes = allClasses//workaround k3
		
		return !self.abstract && 
			self.EStructuralFeatures.exists[st | st instanceof EReference && (st as EReference).containment] &&
			!classes.exists[clazz | self!=clazz && clazz.hasStructFeatureWithType(self)]
	}
	
	public def boolean hasStructFeatureWithType(EClass clazz) {
		return self.EStructuralFeatures.filter(typeof(EReference)).exists[st | st.containment &&
		 	(st.EType.getQualifiedName.equals(clazz.getQualifiedName) || (st.EType instanceof EClass && (st.EType as EClass).isSuperTypeOfBis(clazz)))
 		]
	}
}
