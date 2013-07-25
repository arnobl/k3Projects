package fr.inria.triskell.kompren

import fr.inria.triskell.k3.Aspect
import java.util.List
import org2.kermeta.kompren.slicer.SlicedClass
import org2.kermeta.kompren.slicer.SlicedProperty
import org2.kermeta.kompren.slicer.Slicer

@Aspect(className=typeof(Slicer)) class SlicerAspect {
	public def List<SlicedClass> slicedClasses() {
		return _self.slicedElements.filter(typeof(SlicedClass)).toList
	}
	
	
	public def List<SlicedProperty> slicedProperties() {
		return _self.slicedElements.filter(typeof(SlicedProperty)).toList
	}
}